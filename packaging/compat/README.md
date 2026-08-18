# FPC compat units

`pwd.pp` is an unmodified copy of `packages/users/src/pwd.pp` from the
FPC 3.2.2 sources (LGPL with linking exception, as the rest of the FPC RTL).

Distro-split FPC installs (Debian/Ubuntu `fp-units-*`) do not ship this unit,
but mORMot2 (`mormot.core.os.posix.inc`) needs it. `packaging/build.sh` probes
the installed FPC and, only when the unit is missing, compiles this copy and
puts the resulting binary `.ppu`/`.o` on the unit path. Official FPC builds
(e.g. the ones setup-lazarus installs in CI) already contain it, so the probe
skips the compat copy there.
