{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.tlspool;

  configFile = if cfg.configFile != null then cfg.configFile else pkgs.writeText "tlspool.conf"
    ''
# tlspool.conf - Configuration of the TLS Pool.
# 
# Lines in this file may only hold one of the following forms:
#  - nothing: ignored
#  - only whitespace: ignored
#  - a # sign and arbitrary characters: ignored
#  - a word, a single space and arbitrary characters: a config declaration
#
# The order of declarations matter; if options are undeclared or appear out
# of their expected order they may lead to a syntax error.
#

#
# The TLS Pool is a daemon.  Set its PID file here, to be used in scripts.
#
daemon_pidfile ${cfg.pidfile}

#
# The TLS Pool listens to a UNIX domain socket, reachable to users and groups
# with the proper permissions.  Use mode 0660 to permit same-user and
# same-group access to the TLS Pool.
#
# Note that initial root privileges are needed to be able to change to
# another socket_user and possibly to change the socket_group.  These
# actions are performed before dropping privileges.
#
# Multiple of these may be specified.  They are instantiated at the point
# of the socket_name declaration.  This serves the purpose of a simple
# 
#
socket_user ${cfg.socket_user}
socket_group ${cfg.socket_group}
socket_mode 0666
socket_name  ${cfg.socket}

#
# The TLS Pool usually drops privileges to a lower-ordered user, as
# specified below.  Note that the PKCS #11 interface is a library,
# so it may suffer from a chroot if it operates on locally stored
# data that is not available under the chroot environment.
#
# Note that chroot must be performed before changing user/group.
#
# daemon_chroot /var/chroot/tlspool
daemon_user ${cfg.daemon_user}
daemon_group ${cfg.daemon_user}

#
# The TLS Pool sends output to syslog, using an identity "tlspool" with the
# process number and the daemon facility.
#
# log_level is set to the minimum level to log.  It is set to one of
# EMERG(ENCY), ALERT, CRIT(ICAL), ERR(OR), WARN(ING), NOT(IC)E, INFO
# or DEBUG, which is a list ordered from quiet to verbose.  Brackets
# show what may be taken out to abbreviate a work; you may use * as
# an alias for DEBUG.
#
# log_filter is a comma-separated list of words that signify the kind of
# debugging output to show.  Set to * to produce all possible output.
# Recognised values include:
#  - TLS for TLS-level error messages
#  - PKCS11 for errors in PKCS #11 connections
#  - DB for errors related to management database handling
#  - FILES for errors related to the file system
#  - CRYPTO for cryptographic information
#  - CERT for certificate-related informaction (covers multiple cert types)
#  - USER for errors related to user interactions (such as PIN entry)
#  - AUTHN/AUTHZ/CREDS/SESSION are not yet generated, and may not be specified
#  - COPYCAT for details about the copying between TLS and plaintext
#  - UNIXSOCK for all details related to the UNIX socket of the TLS Pool
#  - DAEMON for daemon-generic notices
#
# log_stderr can be set to case-insensitive YES or 1 or * to specify
# that the output should go to stderr.  Conversely, setting it to 0
# or case-insensitive NO disables copying logger output to stderr.
#
# The loudest logging possible is obtained by setting all variables to *
#
log_level *
log_filter *
log_stderr *

#
# By default, the TLS Pool will offer all facilities that were known
# at compile time.  TLS Pool clients may inquire about facilities
# through the PING command.
#
# An administrator may choose to explicitly deny certain facilities
# or, if he really wants to sit on top of things, he may want to
# explicitly specify facilities to support.  Note that the latter does
# mean that automatic upgrades will not introduce new facilities, and
# it is going to be assumed that the administrator will pick up the
# pieces if that leads to any problems.  For that reason, a setting
# for allow_facilities is discouraged in default configurations.
#
# allow_facilities is a comma-separated list of facility names
#	that will be offered;
# deny_facilities is a comma-separated list of facility	names
#	that will not be offered.
#
# What a facility name occurs in both, the deny_facilities prevails.
#
# Unknown or unsupported facility strings will be silently ignored, so
# correct spelling of the facility names is important!
#
# Facility names that one may currently offer include:
#
# starttls for the PIOC_STARTTLS_V2 command;
# startgss for the to-be-defined PIOC_STARTGSS_V2 command;
# startssh for the to-be-defined PIOC_STARTSSH_V2 command;
# *        for all currently known facilities.
#

allow_facilities *
deny_facilities 

#
# The TLS Pool opens simple BerkeleyDB databases.  Well, simple... they
# may have transactions, distributed replication and much more advanced
# facilities.  They are simple in the sense of being key-to-value maps.
#
# dbenv_dir points to an administrative directory for a DB environment.
# Assign a directory on a persistent local filesystem for variable data
# if you require transactions and/or replication.
#
# db_localid is the filename of a database, defaults to "localid.db".
# When dbenv_dir is set, this is relative to that directory.
#
# db_disclose is the filename of a database, defaults to "disclose.db".
# When dbenv_dir is set, this is relative to that directory.
#
# db_trust is the filename of a database, defaults to "trust.db".
# When dbenv_dir is set, this is relative to that directory.
#

dbenv_dir ${cfg.databaseDir}/${cfg.databasePrefix}
db_localid ../localid.db
db_disclose ../disclose.db
db_trust ../trust.db

#
# The TLS Pool is an application layer over PKCS #11.  Configure which
# PKCS #11 implementation library is used to store certificates and keys.
#
# Select the storage profile to be used for OpenPGP keys; they should
# either be stored as a Vendor Certificate Format 0x80504750 or as a
# binary object.
#
# It is possible to specify multiple PCKS #11 library paths.  These will
# then be added in order.  Note that any configured PIN will be
# removed by the PKCS #11 library path declaration.
#
# You may need to setup the modules in /etc/pkcs11/pkcs11.conf and in
# a file in /etc/pkcs11/modules/ to have it managed and recognised and/or
# accepted by the p11-kit underlying GnuTLS.
#
# The pkcs11_token looks for a named token under the last entered library
# path.  If a pkcs11_pin was previously setup and no pkcs11_path or
# pkcs11_token declaration came along since then, then the PIN will be
# used to access the pkcs11_token without further need to manually
# login to the token.
#
# When no pkcs11_pin is available to a PKCS #11 token, it must be
# submitted to a running TLS Pool daemon by running tlspool a second
# time, with the -p option.  This action will make it iterate over
# all tokens that failed to login yet, and present a PIN request for
# each of them.  When all tokens have successfully logged in, then
# no PIN is requested and the program will terminate immediately.
#
# One way of obtaining the information for construction of PKCS #11 URIs
# is to run something like
#
#	pkcs11-tool --show-info --list-token-slots \
#		--module=/usr/local/lib/softhsm/libsofthsm2.so
#
# another method that lists directly usable pkcs11: URIs is
#
#	p11tool --login --list-all
# or
#	p11tool --login --list-all /usr/local/lib/softhsm/libsofthsm2.so
#
# Usually, a token URI contains the manufacturer and token label fields;
# in addition, it may present the model and serial fields, the latter of
# which would normally be unique for a given manufacturer and model.
#
# Note however, that all use of PKCS #11 will be based on searches for
# objects; so there is no problem if multiple tokens are identified by
# one URI.  The major concern would be to cover them all.
#
# Specifically when using SoftHSMv2, be sure to verify that permissions
# are properly setup for the TLS Pool.  When testdata/Makefile can access
# the token as the running user, that does not imply that the settings for
# daemon_user and daemon_group provide access to the PKCS #11 token from
# the TLS Pool.
#

pkcs11_path ${cfg.pkcs11_path}
pkcs11_pin ${cfg.pkcs11_pin}
pkcs11_token ${cfg.pkcs11_token}

#
# The TLS Pool does not have many configuration settings for TLS.
# This is because such settings are managed through database entries,
# to provide utlimate flexibility and control.
#
# tls_dhparamfile is the filename of a PEM-encoded PKCS #3 file that
# caches Diffie-Hellman parameter information.  If you assign a path,
# the daemon may start a second faster than without.  If a filename
# is configured but the file is non-existent, the TLS Pool will fill
# it with generated parameters.  In fact, the TLS Pool may re-fill
# the file at any time it feels like it.  If you don't provide a file
# all this will still be done, but starting with randomly created
# parameters and stored only internal to the TLS Pool.  Note that the
# contents of this file are not private, but a rogue setup in this
# file might make connection decryption simpler than assumed.
#
# tls_dhparamfile is an optional filename that can be used to cache
# the internally kept Diffie-Hellman parameters.  Having these
# predefined saves generating the parameters at startup time, which
# can help faster startup of the TLS Pool.
#

tls_dhparamfile ${cfg.pkcs11_path}/tlspool-dh-params.pkcs3

#
# The TLS Pool may welcome an Anonymous Precursor for services whose
# protocol would not be at any danger.  There is a theoretic chance of
# bytes being sent between the anonymous encryption establishment and
# the secure renegotiation with authentication.  Such unauthenticated
# data is known to not be a problem to the TLS Pool, but its size should
# be kept limited; it normally is a banner at best.  The parameter
# tls_maxpreauth defines the maximum permissable number of bytes for any
# such unauthenticated data.
#

tls_maxpreauth 32768

#
# The TLS Pool can sign connections with on-the-fly certificates.
# These are signed by a configured cert and key pair.  The subject name
# in the generated certificate will match the localid supplied by the
# application and/or lidentry callback, and other certificate fields
# (such as Extended Key Usage) may be supplied for the IANA-standardised
# service name supplied along with it.  Certificates last from 2 mins
# before the signing time to 3 minutes thereafter and have no CRL or OCSP.
#
# The use of this is to setup locally signed connections, possibly for
# (captive) proxies for HTTPS or other TLS applications.  This can only be
# done on controlled (local) networks, where it is feasible to install the
# signing certificate as an actual signing certificate.
#
# There is no strict reason why the signing certificate pair must be a
# root certificate, even though this is the most likely setup.  It is also
# possible to setup an intermediate certificate, as long as clients can
# locally find the root and intermediate certificates that they need to
# validate the on-the-fly certificate.  This is because the chain sent
# will not contain the certificate specified as _signcert below, nor any
# certificate higher up in the hierarchy.
#
# The value of tls_onthefly_signcert is the file:   URI of its DER certificate;
# the value of tls_onthefly_signkey  is the pkcs11: URI of its private key.
#
# These settings are considered static, that is they are not relaoded on
# a regular basis, nor is there support for rollover, in light of the
# investment needed to install the new root certificates.  This means that
# a new setting requires a restart of the TLS Pool.
#

tls_onthefly_signcert file:../testdata/tlspool-test-flying-signer.der
# tls_onthefly_signkey pkcs11:model=SoftHSM;manufacturer=SoftHSM;serial=1;token=TLS%20Pool%20testdata;id=obj1id;object=obj1label;object-type=private
tls_onthefly_signkey pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;token=TLS_Pool_dev_data;id=%30%36;object=obj6label;type=private

#
# When online validation is performed, DNSSEC is often a requirement as a
# foundation of security.  For that reason, the TLS Pool must be configured
# with a reference to a root key for the . zone.  You can (insecurely)
# retrieve it yourself with
#
#	dig . dnskey | grep 257
#
# but it is safer to get it from a distribution.  We provide it as well,
# but please consider this for testing purposes only.  Packagers specifically
# should try to use a centrally stored key that is updated along with their
# distribution, using its secure update channels.
#
dnssec_rootkey ${pkgs.tlspool}/etc/root.key

#
# The TLS Pool uses a local LDAP proxy which resolves distinguishedNames
# ending in dc ,dc to remote LDAP servers.  It should also store or find
# local public information, such as OpenPGP keys and X.509 certificates.
#
# OpenPGP requires common but non-standard definitions, see
# http://rickywiki.vanrein.org/doku.php?id=globaldir-5-openpgp
#
ldap_proxy ldap://[2001:db8::389:1]
ldap_proxy ldap://[2001:db8::389:2]

#
# The TLS Pool can use memcache as a storage facility for authentication
# and authorization results.  It can be setup with an expiration time as
# is desirable; note that local programs have the ability to bypass the
# cache, so as to ensure tight authentication for the most critical tasks.
#
#TODO# memcache_ttl 3600
#TODO# memcache_host [2001:db8::8000:6]
#TODO# memcache_host [2001:db8::8000:7]

#
# At the expensive of two nested negotiations, it is possible to serve the
# privacy of the connecting parties.  This is possibly when the client
# offers to accept DH-based anonymous service, and when the server welcomes
# it too.  They should also both implement secure re-negotiations.  We
# introduce a new requirement that the program should not continue in that
# mode, but immediately enforce renegotiation of the security parameters.
#
# Note that the conditions can be said to implement a form of opportunistic,
# that is no-guarantees-provided scheme of concealing certificate identities
# from passive observers.  The normal usage mode of TLS simply does not
# work like that.
#
privacy_attempt ${cfg.privacy_attempt}

#
# The ACL is used to define which application may access what
# certificates and keys.  This is useful to avoid too generic access to
# service keys, although it would be exceptional when needed.
#
# The format of an ACL rule is <identity> <who>... where the <identity>
# is either a domain or user@domain and the <who> elements are the
# program paths that may use the keys that implement certificates that
# are named <identity>.
#
# TODO: Is the ACL properly replaced by having multiple UNIX sockets?

#
# Define additional services for Authentication, Authorization and
# Accounting on top of the minimum requirements of the TLS Pool.
# These requirements will be configured as a RADIUS service.
#
# Each of these entries is optional, and entirely independent of the
# other functions.  If not configured, these functions are simply
# passed over; _authn and _authz will implicitly succeed and _acct will
# not be notified about the TLS connection setup.
#
# Note that _acct will be run even when _authn and/or _authz are
# found in the cache.  There is no such thing as caching coins and
# using them forever :)
#
# Also note that RADIUS does not distinguish between authn and authz;
# both are known to it as access requests.  It is possible however, to
# setup different functions that are called in their respective points
# in time.  You are advised to specify different services if you care
# to distinguish these two aspects.  Most people would specify either
# the radius_authn or the radius_authz though.
#
radius_authn ${cfg.radius_authn}
radius_authz ${cfg.radius_authz}
radius_acct ${cfg.radius_acct}

${cfg.extraConfig}
}
    '';

in
{
  options = {
    services.tlspool = {
      enable = mkEnableOption "tlspool service";

      config = mkOption {
        type = types.lines;
        default = "";
        description = "tlspool.conf configuration excluding the daemon username and pid file.";
        example = literalExample ''
            # tlspool.conf - Configuration of the TLS Pool.
            # For a very detailed annotated example config file check:
            # ${pkgs.tlspool}/etc/tlspool.conf
            daemon_pidfile /var/run/tlspool.pid
            socket_user tlspool
            socket_group tlspool
            socket_mode 0666
            socket_name /var/run/tlspool.sock
            daemon_user tlspool
            daemon_group tlspool
            log_level *
            log_filter *
            log_stderr *
            allow_facilities *
            deny_facilities 
            dbenv_dir ../testdata/tlspool.env
            db_localid ../localid.db
            db_disclose ../disclose.db
            db_trust ../trust.db
            pkcs11_path ${pkgs.softhsm}/lib/softhsm/libsofthsm2.so
            pkcs11_pin 1234
            pkcs11_token pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;token=TLS_Pool_dev_data
            tls_dhparamfile ../testdata/tlspool-dh-params.pkcs3
            tls_maxpreauth 32768
            tls_onthefly_signcert file:../testdata/tlspool-test-flying-signer.der
            tls_onthefly_signkey pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;token=TLS_Pool_dev_data;id=%30%36;object=obj6label;type=private
            dnssec_rootkey ${pkgs.tlspool}/etc/root.key
            ldap_proxy ldap://[2001:db8::389:1]
            ldap_proxy ldap://[2001:db8::389:2]
            privacy_attempt no
            radius_authn [2001:db8::123:45]
            radius_authz [2001:db8::123:45]
            radius_acct [2001:db8::123:46]
       '';
      };

      databaseDir = mkOption {
        type = types.path;
        default = "/var/db/tlspool";
        description = "Location of the database directory for tlspool. This path is used
	               for all databases, and subdirectories may be added.";
      };

      databasePrefix = mkOption {
        type = types.str;
        default = "tlspool.env";
        description = "Path for database directory for tlspool.";
      };

      group_daemon = mkOption {
        type = types.str;
        default = "tlspool";
        description = "Group under which tlspool daemon runs.";
      };

      group_socket = mkOption {
        type = types.str;
        default = "tlspool";
        description = "Group that can access tlspool socket.";
      };

      logDir = mkOption {
        type = types.path;
        default = "/var/log/tlspool/";
        description = "Location of the log directory for tlspool.";

      pid = mkOption {
        type = types.str;
        default = "/var/run/tlspool.pid";
        description = "Location of pid file";
      };

      pkcs11_path = mkOption {
        type = types.path;
        default = "${pkgs.softhsm}/lib/softhsm/libsofthsm2.so";
        description = "Path to pkcs11 software implementation.";
      };

      pkcs11_pin = mkOption {
        type = types.str;
        default = "1234";
        description = "Path to pkcs11 software implementation.";
      };

      pkcs11_token = mkOption {
        type = types.str;
	example = "
        default = "pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;token=TLS_Pool_dev_data";
        description = "pkcs11 token to use with tls pool.";
      };

      privacy_attempt = mkOption {
        type = types.str;
        default = "no";
        description = "Attempt to set up anonymous DH connection
	before establishing final TLS session to further enhance
	privacy";
      };

      radius_authn = mkOption {
        type = types.str;
        default = "";
        description = "Radius Authn server to use.";
      };

      radius_authz = mkOption {
        type = types.str;
        default = "";
        description = "Radius Authz server to use.";
      };

      radius_acct = mkOption {
        type = types.str;
        default = "";
        description = "Radius account to use on server.";
      };

      user_daemon = mkOption {
        type = types.str;
        default = "tlspool";
        description = "User account under which tlspool daemon runs.";
      };

      user_socket = mkOption {
        type = types.str;
        default = "tlspool";
        description = "User account that can access tlspool socket.";
      };

    };
  };

  config = mkIf cfg.enable {
    systemd.services.tlspool = {
      description = "tlspool server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        # Make sure log directory exists
        test -d ${cfg.logDir} || {
          printf "Creating initial log directory for tlspool in ${cfg.logDir}"
          mkdir -p  ${cfg.logDir}
          chmod 640 ${cfg.logDir}
          }
        chown -R ${cfg.user}:${cfg.group} ${cfg.logDir}

        # Make sure the deepest path needed for the database exists
	dbPath = ${cfg.databaseDir}/${cfg.databasePrefix}
        test -d $dbPath || {
          printf "Creating database paths for tlspool in $dbPath"
          mkdir -p  $dbPath
          chmod 640 $dbPath
          }
        chown -R ${cfg.user}:${cfg.group} $dbDir
      '';

      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.tlspool}/bin/tlspool -kc ${configFile}";
        Restart = "always";
      };
    };

    users.extraUsers = mkIf (cfg.user == "tlspool") {
      tlspool = {
        group = cfg.group;
        uid = config.ids.uids.tlspool;
      };
    };

    users.extraGroups = mkIf (cfg.group == "tlspool") {
      tlspool = {
        gid = config.ids.gids.tlspool;
      };
    };

  };
}
