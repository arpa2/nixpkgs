# Nix recipe for TLS Pool.

{ pkgs, stdenv, fetchurl, unzip, libtool, pkgconfig, git, p11_kit,
  libtasn1, db, openldap, libmemcached, cyrus_sasl, openssl, softhsm, bash,
  python, libkrb5, quickder, unbound, ldns,
  useSystemd ? true, systemd
}:

let
  gnutls = pkgs.appendToName "static" (pkgs.lib.overrideDerivation pkgs.gnutls35 (a: {
  configureFlagsArray = ("--enable-static"); }));
in

let
  pname = "tlspool";
  version = "20160623";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = ./../../../../../tlspool/. ;

  propagatedBuildInputs = [ python unbound softhsm openldap ];
  buildInputs = [ pkgconfig unzip git gnutls p11_kit.dev libtasn1 db
  libmemcached cyrus_sasl openssl bash quickder libkrb5 ldns libtool ]
  ++ stdenv.lib.optional useSystemd systemd;

  phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];

  patchPhase = ''
    substituteInPlace src/Makefile test/Makefile \
      --replace "\$(PKG_CONFIG)" "${pkgconfig}/bin/pkg-config" \
      --replace "-ldb " "-L${db}/lib -ldb " \
      --replace "-lldap" "-L${openldap.out}/lib -lldap" \
      --replace "-lldns" "-L${ldns}/lib -lldns" \
      --replace "-lsystemd" "-L${systemd}/lib -lsystemd" \
      --replace "\$(UNBOUND_LIBS)" "-L${unbound.lib}/lib -lunbound" \
      --replace "\$(UNBOUND_CFLAGS)" "-I${unbound.lib}/include" \
      substituteInPlace src/online.c \
      --replace "/usr/local/etc/unbound/root.key" "$(pwd)/test/root.key"
    echo "-----BEGIN CERTIFICATE----- MIIDdzCCAl+gAwIBAgIBATANBgkqhkiG9w0BAQsFADBdMQ4wDAYDVQQKEwVJQ0FO TjEmMCQGA1UECxMdSUNBTk4gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxFjAUBgNV BAMTDUlDQU5OIFJvb3QgQ0ExCzAJBgNVBAYTAlVTMB4XDTA5MTIyMzA0MTkxMloX DTI5MTIxODA0MTkxMlowXTEOMAwGA1UEChMFSUNBTk4xJjAkBgNVBAsTHUlDQU5O IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRYwFAYDVQQDEw1JQ0FOTiBSb290IENB MQswCQYDVQQGEwJVUzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKDb cLhPNNqc1NB+u+oVvOnJESofYS9qub0/PXagmgr37pNublVThIzyLPGCJ8gPms9S G1TaKNIsMI7d+5IgMy3WyPEOECGIcfqEIktdR1YWfJufXcMReZwU4v/AdKzdOdfg ONiwc6r70duEr1IiqPbVm5T05l1e6D+HkAvHGnf1LtOPGs4CHQdpIUcy2kauAEy2 paKcOcHASvbTHK7TbbvHGPB+7faAztABLoneErruEcumetcNfPMIjXKdv1V1E3C7 MSJKy+jAqqQJqjZoQGB0necZgUMiUv7JK1IPQRM2CXJllcyJrm9WFxY0c1KjBO29 iIKK69fcglKcBuFShUECAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8B Af8EBAMCAf4wHQYDVR0OBBYEFLpS6UmDJIZSL8eZzfyNa2kITcBQMA0GCSqGSIb3 DQEBCwUAA4IBAQAP8emCogqHny2UYFqywEuhLys7R9UKmYY4suzGO4nkbgfPFMfH 6M+Zj6owwxlwueZt1j/IaCayoKU3QsrYYoDRolpILh+FPwx7wseUEV8ZKpWsoDoD 2JFbLg2cfB8u/OlE4RYmcxxFSmXBg0yQ8/IoQt/bxOcEEhhiQ168H2yE5rxJMt9h 15nu5JBSewrCkYqYYmaxyOC3WrVGfHZxVI7MpIFcGdvSb2a1uyuua8l0BKgk3ujF 0/wsHNeP22qNyVO+XVBzrM8fk8BSUFuiT/6tZTYXRtEt5aKQZgXbKU5dUF3jT9qg j/Br5BZw3X/zd325TvnswzMC1+ljLzHnQGGk -----END CERTIFICATE-----" > $(pwd)/test/root.key
    '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/sbin $out/man
    make DESTDIR=$out PREFIX=/ all
    make DESTDIR=$out PREFIX=/ install
    '';

  meta = with stdenv.lib; {
    description = "A supercharged TLS daemon that allows for easy, strong and consistent deployment";
    license = licenses.bsd2;
    homepage = https://www.tlspool.org;
    maintainers = with maintainers; [ leenaars ];
  };
}
