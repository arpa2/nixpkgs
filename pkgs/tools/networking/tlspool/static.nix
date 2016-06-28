# Nix recipe for TLS Pool.

{ pkgs, stdenv, fetchurl, unzip, libtool, pkgconfig, git, p11_kit,
  libtasn1, db, openldap, libmemcached, cyrus_sasl, openssl, softhsm, bash,
  python, libkrb5, quickder,
  useSystemd ? true, systemd,
  zlibStatic # Necessary for static compilation
  #Defined below: unbound, ldns,
}:

let
  nettle = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.nettle (a: {
  configureFlagsArray = ("--enable-static"); }));
  gmp-static = pkgs.gmp.override { withStatic = true; };
in

let
  libidn = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.libidn (a: {
  configureFlagsArray = ("--enable-static"); }));
in

let
  gnutls = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.gnutls35 (a: {
  configureFlagsArray = ("--enable-static"); }));
in

let
  unbound = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.unbound (a: {
  configureFlagsArray = ("--enable-static"); }));
in

let
  ldns = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.ldns (a: {
  configureFlagsArray = ("--enable-static"); }));
in

let
  pname = "tlspool_static";
  version = "20160627";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = ./../../../../../tlspool/. ;

  propagatedBuildInputs = [ python unbound softhsm openldap ];
  buildInputs = [ pkgconfig unzip git gnutls p11_kit.dev libtasn1 db
  libmemcached cyrus_sasl openssl bash quickder libkrb5 ldns libtool ]
  ++ stdenv.lib.optional useSystemd systemd;

  phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];

  patchPhase = ''
    substituteInPlace src/Makefile test/Makefile \
      --replace "\$(PKG_CONFIG)" "${pkgconfig}/bin/pkg-config" \
      --replace "-ldb " "-L${db}/lib -ldb " \
      --replace "-lldap" "-L${openldap.out}/lib -lldap" \
      --replace "-lldns" "-L${ldns}/lib -lldns" \
      --replace "-lsystemd" "-L${systemd}/lib -lsystemd" \
      --replace "\$(UNBOUND_LIBS)" "-L${unbound.lib}/lib -lunbound" \
      --replace "\$(UNBOUND_CFLAGS)" "-I${unbound.lib}/include" 
      substituteInPlace etc/tlspool.conf \
      --replace "dnssec_rootkey ../etc/root.key" "dnssec_rootkey $out/etc/root.key" \
      --replace "pkcs11_path /usr/local/lib/softhsm/libsofthsm2.so" "pkcs11_path ${softhsm}/lib/softhsm/libsofthsm2.so"
      substituteInPlace src/online.c \
      --replace "/usr/local/etc/unbound/root.key" "$(pwd)/test/root.key"
    '';
#      --replace "\$(LIBS)" "-Wl,-Bstatic ${unbound.lib}/lib/libunbound.a ${gnutls.out}/lib/libgnutls.a ${gnutls.out}/lib/libgnutls-dane.a ${ldns}/lib/libldns.a ${openldap.out}/lib/libldap.a ${openldap.out}/lib/libldap_r.a ${openldap.out}/lib/liblber.a ${zlibStatic.static}/lib/libz.a ${libidn.out}/lib/libidn.a ${nettle.out}/lib/libnettle.a ${nettle.out}/lib/libhogweed.a ${gmp-static.out}/lib/libgmp.a -Wl,-Bdynamic -L${quickder}/lib -lquickder -L${openldap.out}/lib -lldap -L${ldns}/lib -lldns -L${libtasn1}/lib -ltasn1 -L${gnutls}/lib -lgnutls -lgnutls-dane -L${db}/lib -ldb -L${cyrus_sasl}/lib -lsasl2 -L${openssl.dev}/lib -lssl -L${p11_kit}/lib -lp11-kit -L${unbound.lib}/lib -lunbound"
#      --replace "CFLAGS += -pthread -I ../include" "CFLAGS += -pthread -I ../include -I${unbound.out}/include -I${gnutls.dev}/include -I${ldns}/include -I${openldap}/include -I${quickder}/include" \

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    '';

  meta = with stdenv.lib; {
    description = "A supercharged TLS daemon that allows for easy, strong and consistent deployment";
    license = licenses.bsd2;
    homepage = https://www.tlspool.org;
    maintainers = with maintainers; [ leenaars ];
  };
}
