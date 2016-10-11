{ stdenv, fetchurl, fetchFromGitHub }:

let
  version = "alpha2";
in

stdenv.mkDerivation {
  name = "6bed4-${version}";

  src = fetchurl {
    url = http://devel.0cpm.org/6bed4/download/refimpl-01-alpha2.tgz;
    sha256="05sd8bgpd08vmnvsg61c6nmybf1w2jqpa6jab82q3r4lkhx96ys4";
  };

#  src = fetchFromGitHub {
#    owner = "vanrein";
#    repo = "6bed4";
#    rev = "${version}";
#    sha256 = "0dab7x3mhhvbply14m9q3lq8dq0gwa3m2jzywlisg057xc1mpyj7";
#  };

  installPhase = ''
    mkdir -p $out/bin $out/man
    cp 6bed4router 6bed4peer $out/bin
    cp *.man $out/man
   '';

  meta = {
    homepage = http://devel.0cpm.org/6bed4/;
    description = "Instant IPv6 tunnel";
    license = stdenv.lib.licenses.bsd3;
    maintainers = with stdenv.lib.maintainers; [ leenaars ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
