{ stdenv, fetchurl, botan, autoreconfHook }:

stdenv.mkDerivation rec {

  name = "softhsm-${version}";
  version = "2.1.0";

  src = fetchurl {
    url = "https://dist.opendnssec.org/source/${name}.tar.gz";
    sha256 = "0399b06f196fbfaebe73b4aeff2e2d65d0dc1901161513d0d6a94f031dcd827e";
  };

  configureFlags = [
    "--with-crypto-backend=botan"
    "--with-botan=${botan}"
    "--sysconfdir=$out/etc"
    "--localstatedir=$out/var"
    ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ botan ];

  patches = map fetchurl [
  {
    url = "https://github.com/opendnssec/SoftHSMv2/files/197297/softhsmtokendir-stickybit.patch.txt";
    sha256 = "1bxdrr824qldqgqs3h3im4wxqcdp009m29aia0293pmxbfspkgd5";
  }
  ];

  postInstall = "rm -rf $out/var";

  meta = {
    homepage = https://www.opendnssec.org/softhsm;
    description = "Cryptographic store accessible through a PKCS #11 interface";
    license = stdenv.lib.licenses.bsd2;
    maintainers = stdenv.lib.maintainers.leenaars;
    platforms = stdenv.lib.platforms.linux;
  };
}
