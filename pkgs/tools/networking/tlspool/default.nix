# Nix recipe for TLS Pool.

{ pkgs, stdenv, fetchFromGitHub, unzip, libtool, pkgconfig, git, p11_kit,
  libtasn1, db, openldap, libmemcached, cyrus_sasl, openssl, softhsm, bash,
  python, libkrb5, quickder, unbound, ldns, gnupg, gnutls35,
  useSystemd ? true, systemd, swig
}:

let
  pname = "tlspool";
  version = "unstable-20160822";
  gnutls_ = pkgs.gnutls35;
in

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  src = fetchFromGitHub {
     owner  = "arpa2";
     repo  = "tlspool";
     rev    = "219e079dfefbd2c5746d97c4c8f593f991303002";
     sha256 = "0qpxlcalflwajq7lry2fcdc6yikpgj5idp46nyw9agas81pd90ii";
  };

  propagatedBuildInputs = [ python unbound softhsm openldap gnutls35
                            p11_kit.dev p11_kit.out gnupg ];
  buildInputs = [ pkgconfig unzip git libtasn1 db libmemcached cyrus_sasl
                  openssl bash quickder libkrb5 ldns libtool swig
		  pkgs.pythonPackages.pip ]
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
      substituteInPlace lib/Makefile \
      --replace "DESTDIR=\$(DESTDIR) PREFIX=\$(PREFIX)" "DESTDIR=\$(DESTDIR) PREFIX=\$(PREFIX) SWIG=${swig}/bin/swig"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man $out/etc/tlspool/ $out/include/${pname}/pulleyback
    mkdir -p $out/${python.sitePackages}/tlspool
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    cp -R etc/* $out/etc/tlspool/
    cp include/tlspool/*.h $out/include/${pname}
    cp pulleyback/*.h $out/include/${pname}/pulleyback/
    cp src/*.h $out/include/${pname}
    '';

  meta = with stdenv.lib; {
    description = "A supercharged TLS daemon that allows for easy, strong and consistent deployment";
    license = licenses.bsd2;
    homepage = https://www.tlspool.org;
    maintainers = with maintainers; [ leenaars ];
  };
}
