{ stdenv, fetchurl, cmake, git, tlspool, qt5 }:

stdenv.mkDerivation rec {
  name = "tlspool-gui-${version}";
  version = "0.0.2";
  src = ./../../../../../tlspool-gui/. ;

#  src = fetchgit {
#    url = "https://github.com/amarsman/tlspool-gui";
#    rev = "refs/tags/v${version}";
#    sha256 = "";
#  };

  buildInputs = [
    qt5.qtbase qt5.qtsvg qt5.qttranslations cmake git tlspool
  ];

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man
    cp tlspool-gui $out/bin
    '';

  meta = with stdenv.lib; {
    description = "A Qt based GUI for the TLS pool daemon";
    homepage = http://tlspool.org/;
    maintainers = with maintainers; [ leenaars ];
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}

