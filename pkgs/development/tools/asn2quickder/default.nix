{ stdenv, fetchFromGitHub, python, pythonPackages, buildPythonPackage, asn1ate, makeWrapper }:

buildPythonPackage rec {
  pname = "asn2quickder";
  name = "${pname}-${version}";
  version = "0.6-RC1";

  src = fetchFromGitHub {
    sha256 = "0srm6p8590fpfj0afgf33s6b88xsllgszgi8z89s1667cnmiz2zb";
    rev = "version-${version}";
    owner = "vanrein";
    repo = "${pname}";
  };

  propagatedBuildInputs = [ python pythonPackages.pyparsing asn1ate makeWrapper ];

  patchPhase = ''
    substituteInPlace Makefile \
      --replace '..' ':${asn1ate}/${python.sitePackages}:$(DESTDIR)/{python.sitePackages}:${pythonPackages.pyparsing}/${python.sitePackages}' \
      --replace '$(PREFIX)/lib/asn2quickder' '~/.nix-profile/${python.sitePackages}'
    '';

  installPhase = ''
    mkdir -p $out/${python.sitePackages}/
    mkdir -p $out/bin $out/lib $out/sbin $out/man
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    cp asn1ate/asn2quickder.py $out/bin/asn2quickder
    '';

  postInstall = ''
      wrapProgram $out/bin/asn2quickder
    '';


  meta = with stdenv.lib; {
    description = "An ASN.1 compiler with a backend for Quick DER";
    homepage = https://github.com/vanrein/asn2quickder;
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ leenaars ];
  };
}
