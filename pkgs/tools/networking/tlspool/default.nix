# Nix recipe for TLS Pool.

{ pkgs, stdenv, fetchurl, unzip, libtool, pkgconfig, git, p11_kit,
  libtasn1, db, openldap, libmemcached, cyrus_sasl, openssl, softhsm, bash,
  python, libkrb5, quickder, unbound, ldns,
  useSystemd ? true, systemd
}:

let
  gnutls = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.gnutls35 (a: {
  configureFlagsArray = ("--enable-static"); }));
in

let
  pname = "tlspool";
  version = "20160626";
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
'';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man $out/etc/tlspool/
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    cp -R etc/* $out/etc/tlspool/
    '';

  meta = with stdenv.lib; {
    description = "A supercharged TLS daemon that allows for easy, strong and consistent deployment";
    license = licenses.bsd2;
    homepage = https://www.tlspool.org;
    maintainers = with maintainers; [ leenaars ];
  };
}
