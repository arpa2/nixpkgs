# Nix recipe for TLS Pool.

{ stdenv, fetchurl, unzip, libtool, pkgconfig, git, gnutls35, p11_kit,
  libtasn1, db, openldap, libmemcached, cyrus_sasl, openssl, softhsm, bash,
  python, ldns, unbound, quickder, libkrb5
}:

let
  pname = "tlspool";
  version = "20160620";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = ./../../../../../tlspool/. ;

  propagatedBuildInputs = [ python ];
  buildInputs = [ pkgconfig unzip git gnutls35 p11_kit libtasn1 db openldap
  libmemcached cyrus_sasl openssl softhsm bash unbound quickder libkrb5 ldns ];

  phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];

  patchPhase = ''
    substituteInPlace test/Makefile \
      --replace "LDFLAGS =" "LDFLAGS = -L${unbound}/lib -L${gnutls35}/lib -L${ldns}/lib -L${openldap}/lib" \
      --replace "shell pkg-config" "${pkgconfig}/bin/pkg-config" \
      --replace "-lldns" "-L${ldns.out}/lib" \
      --replace "-lldap" "-L${openldap.out}/lib" \
      --replace "-lunbound" "-L${unbound}/lib -L${gnutls35}/lib" \
#      --replace "onlinecheck testonline" "#onlinecheck testonline" 
    '';

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
