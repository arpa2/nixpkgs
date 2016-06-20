{ stdenv, fetchFromGitHub, fetchurl, hexio, python, which, asn2quickder, bash }:

stdenv.mkDerivation rec {
  pname = "quickder";
  name = "${pname}-${version}";
  version = "0.1-RC5";

  src = fetchFromGitHub {
    sha256 = "0azasql4q6nyig23w9mca4vfn84ircwy9vr7s626ky5aahgni7fb";
    rev = "version-${version}";
    owner = "vanrein";
    repo = "quick-der";
  };

  # For development you can use src = ../../../../../quick-der/. ;

  phases = [ "unpackPhase" "patchPhase" "installPhase" ];

  buildInputs = [ python which asn2quickder bash ];

  patchPhase = ''
    substituteInPlace Makefile \
      --replace 'lib tool test rfc' 'lib test rfc'
    substituteInPlace ./rfc/Makefile \
      --replace 'ASN2QUICKDER_CMD = ' 'ASN2QUICKDER_CMD = ${asn2quickder}/bin/asn2quickder #'
    '';

  installFlags = "ASN2QUICKDER_DIR=${asn2quickder}/bin ASN2QUICKDER_CMD=${asn2quickder}/bin/asn2quickder";
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
