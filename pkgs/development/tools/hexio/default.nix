{ stdenv, fetchFromGitHub, fetchurl, python, pcsclite, pth, glibc }:

stdenv.mkDerivation rec {
  pname = "hexio";
  name = "${pname}-${version}";
  version = "201605";

  src = fetchFromGitHub {
    sha256 = "0zz0d1j3srp0iyh6wn9mczn7w4pbnaimrgdldkkb5wwzcm40caxa";
    rev = "dcc5f9ca71bde24fd8ad7a47ea86f8bd221b7103";
    owner = "vanrein";
    repo = "hexio";
  };

  buildInputs = [ python pcsclite pth glibc ];

  patchPhase = ''
    substituteInPlace Makefile \
      --replace '-I/usr/local/include/PCSC/' '-I${pcsclite}/include/PCSC/' \
      --replace '-L/usr/local/lib/pth' '-I${pth}/lib/'
    '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    '';

  meta = with stdenv.lib; {
    description = "Low-level I/O helpers for hexadecimal, tty/serial devices and so on";
    homepage = https://github.com/vanrein/hexio;
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ leenaars ];
  };
}
