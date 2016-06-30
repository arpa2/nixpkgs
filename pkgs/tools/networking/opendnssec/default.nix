{ stdenv, fetchFromGitHub, pkgconfig, autoreconfHook, ldns, sqlite,
  libxml2, jre, libtool, softhsm, openssl, gettext }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "opendnssec-${version}";
  version = "2.0.0rc2";

  src = fetchFromGitHub {
    owner = "opendnssec";
    repo = "opendnssec";
    rev = "${version}";
    sha256 = "1cgx6drg4j9l79n1q0xk5vyyf8rxfcgs5al9gyw69sgn2xm7dj64";
  };

  nativeBuildInputs = [ pkgconfig autoreconfHook ];

  buildInputs = [ gettext libtool ldns sqlite libxml2 jre ]; # ++ optional stdenv.isLinux systemd;

  patchPhase = ''
  substituteInPlace configure.ac "ACX_LDNS" "#ACX_LDNS" 
  '';


  preconfigurePhase = ''
    autogen.sh
    export LDNS_CONFIG=${ldns}/bin/ldns-config
    '';
 
/*
  configureFlags = ''
    --with-ldns=${ldns}/lib
    --with-libxml2=${libxml2}/lib/libxml2.so
    --with-pkcs11-softhsm=${softhsm}/lib
    --with-ssl=${openssl}/lib
    --with-gnu-ld
    '';
*/

  outputs = [ "out" "man" ];

  meta = {
    description = "An open-source turn-key solution for deploying DNSSEC";
    homepage = https://opendnssec.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [ leenaars ];
    platforms = with platforms; allBut [ darwin ];
  };
}
