{ callPackage, fetchFromGitHub, autoreconfHook, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "kdh-3.4.12";

  src = fetchFromGitHub {
    owner = "arpa2";
    repo = "gnutls-kdh";
    rev = "c45db81e60336ae9ac104d8fd5fc54aa1f8546fc";
    sha256 = "0qnpvkgis3kq9k567x4rkf3w5bv26a56514n3d8abzs5g6v70hzw";
  };

  # This fixes some broken parallel dependencies
  postPatch = ''
    sed -i 's,^BUILT_SOURCES =,\0 systemkey-args.h,g' src/Makefile.am
  '';

  nativeBuildInputs = [ autoreconfHook ];
})
