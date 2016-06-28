# Nix recipe for TLS Pool.

{ pkgs, stdenv, fetchurl, cmake, openldap, sqlite, log4cplus, fcgi,
  pkgconfig, flex, flexcpp, bison
#  unzip, libtool, pkgconfig, git, p11_kit,
#  libtasn1, db, openldap, libmemcached, cyrus_sasl, openssl, softhsm, bash,
#  python, libkrb5, quickder, unbound, ldns,
#  useSystemd ? true, systemd
}:

#let
#  gnutls = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.gnutls35 (a: {
#  configureFlagsArray = ("--enable-static"); }));
#in

let
  pname = "steamworks";
  version = "20160628";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = ./../../../../steamworks/. ;

  propagatedBuildInputs = [ ];
  buildInputs = [ pkgconfig openldap sqlite cmake flex bison flexcpp ];

#  ++ stdenv.lib.optional useSystemd systemd;

  patchPhase = ''
    make
  '';

#  phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];
#
#  patchPhase = ''
#    substituteInPlace src/Makefile test/Makefile \
#      --replace "\$(PKG_CONFIG)" "${pkgconfig}/bin/pkg-config" \
#'';

#  installPhase = ''
#    mkdir -p $out/bin $out/lib $out/sbin $out/man $out/etc/tlspool/
#    make DESTDIR=$out PREFIX=/ all
#    make DESTDIR=$out PREFIX=/ install
#    cp -R steamworks $out/bin
#    '';

  meta = with stdenv.lib; {
    description = "Configuration information distributed over LDAP in near realtime";
    license = licenses.bsd2;
    homepage = https://www.arpa2.net;
    maintainers = with maintainers; [ leenaars ];
  };
}
