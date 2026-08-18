{ NetResolve - dual-stack (IPv4/IPv6) host resolution for mORMot sockets.

  On POSIX mORMot resolves host names with gethostbyname(), which only
  returns A records: a host that is reachable over IPv6 only (or whose
  IPv4 route is dead, e.g. a VPN handing out synthetic 198.18.x.x
  addresses) can never be connected. This unit plugs a resolver based on
  getaddrinfo() into mORMot's NewSocketAddressCache hook, so NewSocket()
  gets an address of whichever family actually answers, without patching
  the mORMot submodule.

  When a name resolves to several addresses, each one is probed with a
  short TCP connect on the target port and the first one that answers is
  used; if none answers within the probe timeout, the first address (in
  getaddrinfo/RFC 6724 order) is returned so that the caller reports the
  real connect error. }

unit NetResolve;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

// idempotent; ProbePort is the TCP port used to probe multi-homed hosts
procedure InstallDualStackResolver(ProbePort: Word);

implementation

{$IFDEF UNIX}

uses
  ctypes, BaseUnix, Sockets,
  mormot.core.base, mormot.net.sock;

{$PACKRECORDS C}
type
  PAddrInfo = ^TAddrInfo;
  TAddrInfo = record
    ai_flags: cint;
    ai_family: cint;
    ai_socktype: cint;
    ai_protocol: cint;
    ai_addrlen: cuint;      // socklen_t
    ai_addr: Pointer;       // struct sockaddr *
    ai_canonname: PAnsiChar;
    ai_next: PAddrInfo;
  end;
{$PACKRECORDS DEFAULT}

function getaddrinfo(name, service: PAnsiChar; hints: PAddrInfo;
  out res: PAddrInfo): cint; cdecl; external 'c';
procedure freeaddrinfo(res: PAddrInfo); cdecl; external 'c';

const
  PROBE_TIMEOUT_MS = 1500;

type
  TDualStackResolver = class(TInterfacedObject, INewSocketAddressCache)
  private
    fProbePort: Word;
  public
    function Search(const Host: RawUtf8; out NetAddr: TNetAddr): boolean;
    procedure Add(const Host: RawUtf8; const NetAddr: TNetAddr);
    procedure Flush(const Host: RawUtf8);
    procedure SetTimeOut(aSeconds: integer);
    procedure Force(const Host, IP: RawUtf8);
  end;

var
  GResolver: TDualStackResolver; // owned by the NewSocketAddressCache interface

function TryConnect(ai: PAddrInfo; port: Word; timeoutMs: Integer): Boolean;
var
  s: cint;
  tv: TTimeVal;
begin
  Result := False;
  // sin_port and sin6_port share offset 2 in sockaddr_in/sockaddr_in6
  PWord(PAnsiChar(ai^.ai_addr) + 2)^ := bswap16(port);
  s := fpsocket(ai^.ai_family, SOCK_STREAM, 0);
  if s < 0 then
    exit;
  tv.tv_sec := timeoutMs div 1000;
  tv.tv_usec := (timeoutMs mod 1000) * 1000;
  fpsetsockopt(s, SOL_SOCKET, SO_SNDTIMEO, @tv, SizeOf(tv));
  fpsetsockopt(s, SOL_SOCKET, SO_RCVTIMEO, @tv, SizeOf(tv));
  Result := fpconnect(s, ai^.ai_addr, ai^.ai_addrlen) = 0;
  FpClose(s);
end;

function TDualStackResolver.Search(const Host: RawUtf8;
  out NetAddr: TNetAddr): boolean;
var
  hints: TAddrInfo;
  res, ai, best: PAddrInfo;
begin
  Result := False;
  FillChar(NetAddr, SizeOf(NetAddr), 0);
  FillChar(hints, SizeOf(hints), 0);
  hints.ai_family := AF_UNSPEC;
  hints.ai_socktype := SOCK_STREAM;
  res := nil;
  if (Host = '') or
     (getaddrinfo(PAnsiChar(pointer(Host)), nil, @hints, res) <> 0) or
     (res = nil) then
    exit; // NewSocket() falls back to mORMot's own resolution
  try
    if res^.ai_next = nil then
      best := res
    else
    begin
      best := nil;
      ai := res;
      while ai <> nil do
      begin
        if TryConnect(ai, fProbePort, PROBE_TIMEOUT_MS) then
        begin
          best := ai;
          break;
        end;
        ai := ai^.ai_next;
      end;
      if best = nil then
        best := res; // nothing answered: let the caller report the error
    end;
    if best^.ai_addrlen <= SizeOf(NetAddr) then
    begin
      // TNetAddr is an opaque sockaddr buffer; the caller sets the port
      Move(best^.ai_addr^, NetAddr, best^.ai_addrlen);
      Result := True;
    end;
  finally
    freeaddrinfo(res);
  end;
end;

procedure TDualStackResolver.Add(const Host: RawUtf8; const NetAddr: TNetAddr);
begin
  // Search resolves on every call: nothing to store
end;

procedure TDualStackResolver.Flush(const Host: RawUtf8);
begin
end;

procedure TDualStackResolver.SetTimeOut(aSeconds: integer);
begin
end;

procedure TDualStackResolver.Force(const Host, IP: RawUtf8);
begin
end;

procedure InstallDualStackResolver(ProbePort: Word);
begin
  if GResolver = nil then
  begin
    GResolver := TDualStackResolver.Create;
    NewSocketAddressCache := GResolver;
  end;
  GResolver.fProbePort := ProbePort;
end;

{$ELSE}

// on Windows mORMot already resolves via getaddrinfo(): nothing to do
procedure InstallDualStackResolver(ProbePort: Word);
begin
end;

{$ENDIF}

end.
