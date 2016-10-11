# Nix recipe for ARPA2 Steamworks demo.

{ pkgs, stdenv, fetchurl, cmake, openldap, sqlite, log4cpp, fcgi,
  pkgconfig, flex, flexcpp, bison, nginx, steamworks
}:

let
  pname = "steamworks-demo";
  version = "20160704";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = ./../../../../steamworks/. ;

  propagatedBuildInputs = [ steamworks nginx ];
  buildInputs = [ pkgconfig openldap sqlite cmake flex bison flexcpp log4cpp ];

  dontUseCmakeBuildDir = true;
  dontFixCmake = true;

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man $out/share/steamworks
    cd src/frontend
    make CGI_SOCKET_DIR="$out/share/steamworks"
  '';

  meta = with stdenv.lib; {
    description = "ARPA2 Steamworks demonstration";
    license = licenses.bsd2;
    homepage = https://www.arpa2.net;
    maintainers = with maintainers; [ leenaars ];
  };
}
