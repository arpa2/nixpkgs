{ stdenv, fetchFromGitHub, python, pythonPackages, buildPythonPackage, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "asn2quickder";
  name = "${pname}-${version}";
  version = "0.6-RC1";

  src = fetchFromGitHub {
    sha256 = "0cl0q5mh6nlgwhv13ybw2xv8iwhy60pg9kq0d4wqn2q5nmf35ian";
    # rev = "version-${version}";
    rev = "f15d9bfc1160d234972183b9ab623f6c8c461819";
    owner = "leenaars";
    repo = "${pname}";
  };

  # Working locally you could use src = ../../../../../asn2quickder/. ;

  propagatedBuildInputs = [ python pythonPackages.pyparsing makeWrapper ];

  patchPhase = ''
    substituteInPlace Makefile \
      --replace '..' '..:$(DESTDIR)/{python.sitePackages}:${pythonPackages.pyparsing}/${python.sitePackages}' \
    '';

  installPhase = ''
    mkdir -p $out/${python.sitePackages}/
    mkdir -p $out/bin $out/lib $out/sbin $out/man
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    '';

  meta = with stdenv.lib; {
    description = "An ASN.1 compiler with a backend for Quick DER";
    homepage = https://github.com/vanrein/asn2quickder;
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ leenaars ];
  };
}
