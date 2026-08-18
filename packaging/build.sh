#!/usr/bin/env bash
#
# build.sh — compile LDAP Admin with lazbuild.
# Assumes lazbuild + fpc are already on PATH (CI installs them via
# setup-lazarus on Ubuntu / pacman on Arch).
#
# Env knobs:
#   CPU               target CPU                 (default: x86_64)
#   WIDGETSET         LCL widgetset              (default: qt5)
#   BUILD_MODE        Lazarus build mode         (default: Linux)
#   LAZARUSDIR        Lazarus install dir        (default: auto-detected)
#   GCC_LIBPATH_FIX   1 = add the host gcc lib dir to the FPC library path.
#                     Needed where the gcc is newer than FPC 3.2.2 knows about
#                     (e.g. Arch's gcc 16), which otherwise fails to find
#                     crtbeginS.o at link time. Requires /etc/fpc.cfg to exist.
#   STATIC_URL        mORMot2 static libs archive (default: synopse.info)
#
set -euo pipefail

CPU="${CPU:-x86_64}"
WIDGETSET="${WIDGETSET:-qt5}"
BUILD_MODE="${BUILD_MODE:-Linux}"
STATIC_URL="${STATIC_URL:-https://synopse.info/files/mormot2static.7z}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

echo "==> Initialising submodules (mORMot2)"
git submodule update --init --recursive

# mORMot2 links prebuilt static objects (crc32c, sqlite3, ...) that are NOT
# stored in git; fetch them once into submodules/mORMot2/static/.
STATIC_DIR="submodules/mORMot2/static/$CPU-linux"
if ! ls "$STATIC_DIR"/*.o >/dev/null 2>&1; then
  echo "==> Fetching mORMot2 static libraries"
  tmp7z="$(mktemp --suffix=.7z)"
  curl -fL --retry 3 -o "$tmp7z" "$STATIC_URL"
  SEVENZ="$(command -v 7za || command -v 7z || command -v 7zr)"
  [ -n "$SEVENZ" ] || { echo "build.sh: need 7z/7za (install p7zip)"; exit 1; }
  ( cd submodules/mORMot2 && rm -rf static && "$SEVENZ" x "$tmp7z" -ostatic >/dev/null )
  rm -f "$tmp7z"
fi

# Distro-split FPC installs (Debian/Ubuntu fp-units-*) do not ship the RTL
# 'pwd' unit that mORMot2 needs; official FPC builds do. Probe the compiler
# and, only when the unit is missing, compile the vendored copy from
# packaging/compat/. Only the binary .ppu/.o are exposed on the unit path —
# leaving the source there would let later compiles rebuild it with different
# flags and fail on PPU checksum mismatches.
PWD_UNIT_DIR=""
probe_dir="$(mktemp -d)"
printf 'program p; uses pwd; begin end.\n' > "$probe_dir/p.pp"
if ! fpc -FE"$probe_dir" "$probe_dir/p.pp" >/dev/null 2>&1; then
  echo "==> FPC lacks the 'pwd' unit; compiling vendored compat copy"
  PWD_UNIT_DIR="$ROOT/.cache/fpc/compat-units"
  rm -rf "$PWD_UNIT_DIR" && mkdir -p "$PWD_UNIT_DIR"
  cp "$SCRIPT_DIR/compat/pwd.pp" "$PWD_UNIT_DIR/"
  ( cd "$PWD_UNIT_DIR" && fpc -O2 -FE. pwd.pp >/dev/null && rm pwd.pp )
fi
rm -rf "$probe_dir"

# Optionally teach FPC where the (too-new) gcc runtime objects live, and/or
# add the compat unit dir — without clobbering the system config: our fpc.cfg
# includes /etc/fpc.cfg and appends the extra paths. Requires /etc/fpc.cfg.
if [ -n "$PWD_UNIT_DIR" ] || [ "${GCC_LIBPATH_FIX:-0}" = "1" ]; then
  mkdir -p "$ROOT/.cache/fpc"
  {
    printf '#INCLUDE /etc/fpc.cfg\n'
    if [ "${GCC_LIBPATH_FIX:-0}" = "1" ]; then
      GCC_DIR="/usr/lib/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)"
      echo "==> Adding gcc library path: $GCC_DIR" >&2
      printf -- '-Fl%s\n' "$GCC_DIR"
    fi
    if [ -n "$PWD_UNIT_DIR" ]; then
      printf -- '-Fu%s\n' "$PWD_UNIT_DIR"
    fi
  } > "$ROOT/.cache/fpc/fpc.cfg"
  export PPC_CONFIG_PATH="$ROOT/.cache/fpc"
fi

LAZ_ARGS=()
if [ -n "${LAZARUSDIR:-}" ]; then
  LAZ_ARGS+=(--lazarusdir="$LAZARUSDIR")
else
  # Auto-detect the Lazarus directory (the one holding packager/globallinks).
  gl="$(find /usr -path '*/packager/globallinks' -type d 2>/dev/null | head -1 || true)"
  [ -n "$gl" ] && LAZ_ARGS+=(--lazarusdir="$(dirname "$(dirname "$gl")")")
fi

echo "==> Registering mORMot2 Lazarus package"
lazbuild "${LAZ_ARGS[@]}" --add-package-link submodules/mORMot2/packages/lazarus/mormot2.lpk >/dev/null

# Stale PPUs from a build of a different source revision can crash FPC 3.2.2
# with "Internal error 200611031" in unrelated units; always start clean.
rm -rf Source/ppu

echo "==> Building LdapAdmin (cpu=$CPU ws=$WIDGETSET mode=$BUILD_MODE)"
lazbuild "${LAZ_ARGS[@]}" \
  --cpu="$CPU" \
  --widgetset="$WIDGETSET" \
  --build-mode="$BUILD_MODE" \
  Source/LdapAdmin.lpi

test -x Source/LdapAdmin
echo "==> Built: $ROOT/Source/LdapAdmin"
file Source/LdapAdmin
