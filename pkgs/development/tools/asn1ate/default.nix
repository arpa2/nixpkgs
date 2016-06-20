{ stdenv, fetchFromGitHub, python, pythonPackages, buildPythonPackage, self }:

let
  pname = "asn1ate";
  owner = "kimgr";
in

buildPythonPackage rec {
  name = "${pname}-${version}";
  version = "c56104e8912400135509b584d84423ee05a5af6b";

  src = fetchFromGitHub {
    sha256 = "04pddr1mh2v9qq8fg60czwvjny5qwh4nyxszr3qc4bipiiv2xk9w";
    rev = "${version}";
    owner = "kimgr";
    repo = pname;
  };

  propagatedBuildInputs = [ python pythonPackages.pyparsing ];

  meta = with stdenv.lib; {
    description = "Python library for translating ASN.1 into other forms.";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ leenaars ];
  };
}
