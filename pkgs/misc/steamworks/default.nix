# Nix recipe for ARPA2 Steamworks.

{ pkgs, stdenv, fetchurl, cmake, openldap, sqlite, log4cpp, fcgi,
  pkgconfig, flex, bison
}:

let
  pname = "steamworks";
  version = "20160822";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = ./../../../../steamworks/. ;

  propagatedBuildInputs = [ ];
  buildInputs = [ pkgconfig openldap sqlite cmake flex bison log4cpp ];

  dontUseCmakeBuildDir = true;
  dontFixCmake = true;

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    make build
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/share/man
    cd build
    cp crank/crank pulley/pulley shaft/shaft 3rdparty/fcgi-*/cgi-fcgi $out/bin
#   cp common/lib* 3rdparty/fcgi*/libfcgi.a pulley/pulleyscript/lib* $out/lib
    cp pulley/pulleyscript/compiler $out/bin/compiler_pulleyscript
    cp pulley/pulleyscript/simple $out/bin/simple_pulleyscript
    '';

  meta = with stdenv.lib; {
    description = "Configuration information distributed over LDAP in near realtime";
    license = licenses.bsd2;
    homepage = https://www.arpa2.net;
    maintainers = with maintainers; [ leenaars ];
  };
}
