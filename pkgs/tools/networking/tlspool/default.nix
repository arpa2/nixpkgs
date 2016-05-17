# Nix recipe for TLS Pool. 

{ stdenv, fetchurl, unzip, libtool, pkgconfig, git, gnutls, p11_kit,
  libtasn1, db, openldap, libmemcached, cyrus_sasl, openssl, softhsm, python
}:   

let 
  pname = "tlspool";
  version = "20160420";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = ./../../../../../../software/tlspool/. ;

  buildInputs = [ pkgconfig unzip git gnutls p11_kit libtasn1 db openldap
  libmemcached cyrus_sasl openssl softhsm python];

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  
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
