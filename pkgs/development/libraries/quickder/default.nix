{ stdenv, fetchFromGitHub, fetchurl, hexio, python, which, asn2quickder }:

stdenv.mkDerivation rec {
  pname = "quickder";
  name = "${pname}-${version}";
  version = "0.1-RC2";

  src = fetchFromGitHub {
    sha256 = "1893wk2pkl20gxyrzd99y2vyiqdl55ln8qkz715rvm1m3clicbh3";
    rev = "a09680a4cadfd674dcb28c887f7ed954b20423bf";
    owner = "vanrein";
    repo = "quick-der";
  };

  buildInputs = [ python hexio which asn2quickder];

  patchPhase = ''
    substituteInPlace Makefile \
      --replace 'lib tool test rfc' 'lib test rfc' 
    '';

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
