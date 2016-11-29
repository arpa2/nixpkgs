{ stdenv, fetchurl, mecab, kytea, libedit, pkgconfig
, suggestSupport ? false, zeromq, libevent, libmsgpack
, lz4Support ? false, lz4
, zlibSupport ? false, zlib
}:

stdenv.mkDerivation rec {

  name    = "groonga-${version}";
  version = "6.1.0";

  src = fetchurl {
    url    = "http://packages.groonga.org/source/groonga/${name}.tar.gz";
    sha256 = "03wz6zjql211dd8kvzcqyzkc8czd8gayr7rw5v274lajcs8f6rkb";
  };

  buildInputs = with stdenv.lib; [ pkgconfig mecab kytea libedit ] ++
    optional lz4Support lz4 ++
    optional zlibSupport zlib ++
    optional suggestSupport [ zeromq libevent libmsgpack ];

  configureFlags = with stdenv.lib; ''
    ${optionalString zlibSupport "--with-zlib"}
    ${optionalString lz4Support "--with-lz4"}
  '';

  doInstallCheck = true;

  installCheckPhase = "$out/bin/groonga --version";

  meta = with stdenv.lib; {
    homepage = http://groonga.org/;
    description = "An open-source fulltext search engine and column store";

    longDescription = ''
      Groonga is an open-source fulltext search engine and column store. 
      It lets you write high-performance applications that requires fulltext search.
    '';

    license = licenses.lgpl21;

    maintainers = [ maintainers.ericsagnes ];
    platforms = platforms.linux;
  };

}
