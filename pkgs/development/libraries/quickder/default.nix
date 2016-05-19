{ stdenv, fetchFromGitHub, fetchurl, hexio, python }:

stdenv.mkDerivation rec {
  pname = "quickder";
  name = "${pname}-${version}";
  version = "0.1-RC1";

  src = fetchFromGitHub {
    sha256 = "1p7n1z5k6y8lg1dp5d45zsak6m8daq4gmgrsl0f53y3ciwz1f89k";
    rev = "version-${version}";
    owner = "vanrein";
    repo = "quick-der";
  };

  buildInputs = [ python hexio ];

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    '';

  meta = with stdenv.lib; {
    description = "Quick (and Easy) DER, a Library for parsing ASN.1";
    homepage = https://github.com/vanrein/quick-der;
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ leenaars ];
  };
}
