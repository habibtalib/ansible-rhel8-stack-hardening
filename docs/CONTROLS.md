# Controls

IDs are this kit's own. CIS references are to the CIS Red Hat Enterprise Linux 8, Oracle Database 19c, PostgreSQL and MySQL 8 benchmarks; section numbers shift between benchmark versions, so check the version your scanner uses.

| ID | Control | CIS reference | Role / task | Default | Restart | Risk |
|---|---|---|---|---|---|---|
| OS-01 | Blacklist unused kernel modules (firewire, atm, can, cramfs, squashfs, udf) | RHEL 8 1.1.1.x, 3.2.x | os_hardening / OS-01 | on | none (reboot to unload) | Low. SCTP excluded unless `os_blacklist_sctp` |
| OS-02 | `dmesg_restrict`, `kptr_restrict`, `yama.ptrace_scope` | 1.5.x | OS-02 | on | none | Low. `ptrace_scope=2` breaks debuggers; default 1 |
| OS-03 | IPv4 forwarding off | 3.1.x | OS-03 | on, skipped on Docker hosts | none | High on Docker hosts (published ports stop) |
| OS-04 | `gpgcheck=1` on repos | 1.2.x | OS-04 | on | none | Medium: unsigned local repos stop installing. Use `os_gpgcheck_exempt_files` |
| OS-05 | Unused services off; rpcbind masked (opt-in) | 2.2.x | OS-05 | services on, rpcbind off | stop | Medium for rpcbind: check reverse dependencies |
| OS-06 | at/cron allow root only | 5.1.x | OS-06 | on | none | Low |
| OS-07 | pwquality, `PASS_MAX_DAYS`, `PASS_WARN_AGE`, chage for listed users | 5.4.x, 5.5.x | OS-07 | on (chage: empty list) | none | Medium: never age application service accounts |
| OS-08 | SSH `DenyUsers` for service accounts | 5.2.x | OS-08 | off (empty list) | sshd reload | Low; validated with `sshd -t` |
| OS-09 | rsyslog `$FileCreateMode 0640`; AIDE; journal-remote | 4.2.x, 1.3.x | OS-09 | mode on, packages off | rsyslog restart | Low |
| OS-10 | Unowned / ungrouped files fixed in named paths | 6.1.x | OS-10 | off (empty list) | none | High if pointed at container data; never use `/` |
| OS-11 | ICMP timestamp request/reply blocked | VA finding (CVE-1999-0524) | OS-11 | off | none | Low; pick the firewall backend in use |
| DB-01 | sqlnet.ora AES256 encryption + SHA-2 integrity, REQUIRED | Oracle 19c 2.2.x | oracle_hardening / DB-01 | off | clients reconnect | High: test every client and Data Guard redo first |
| DB-01b | `SQLNET.ALLOWED_LOGON_VERSION_SERVER=12a` | 2.2.x | DB-01 | off | none | Medium: accounts with only old verifiers cannot log in |
| DB-02 | `ACCEPT_MD5_CERTS`/`ACCEPT_SHA1_CERTS = FALSE` | 2.2.x | DB-02 | on | none | Low (no effect without TCPS) |
| DB-03 | `PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION` on DEFAULT | 3.x | DB-03 | on | none | Low; affects new passwords only |
| DB-04 | `SEC_PROTOCOL_ERROR_TRACE_ACTION=LOG` | 2.x | DB-04 | on | none | Low |
| DB-05 | Unified audit `ORA_LOGON_FAILURES`, `ORA_SECURECONFIG` | 5.x | DB-05 | on | none | Low; watch audit trail growth |
| DB-06 | Revoke ANY / PUBLIC synonym privileges from app schemas | 4.x | DB-06 | off (empty list) | none | Medium: confirm with the vendor |
| DB-07 | Mode 0640 on files holding DB credentials | — | DB-07 | off (empty list) | none | Low |
| DB-10 | Connection, disconnection, DDL and replication logging | PostgreSQL 3.x | postgresql_hardening | on | reload | Low; log volume grows |
| DB-11 | `ssl=on`, TLS 1.2+, strong ciphers | 6.x | postgresql_hardening | off | reload (ssl) | Medium: certificate and key must exist |
| DB-12 | `passwordcheck` in `shared_preload_libraries` | 5.x | postgresql_hardening | off | restart | Medium: rolling restart |
| DB-13 | No local `trust` in pg_hba.conf | 5.x | postgresql_hardening / DB-13 | off | reload | Medium: scripts using trust must use peer or a password |
| DB-20 | MySQL `validate_password` MEDIUM | MySQL 8 7.x | mysql_hardening | off | none | Low; new passwords only |
| DB-30 | MongoDB auth / exposure report | MongoDB 2.x | mongodb_checks | report | none | None |
| DB-31 | MongoDB data directory 0750 | 5.x | mongodb_checks | off (empty list) | none | Low |
| WEB-01 | Tomcat error page without version / stack trace | Tomcat 9 2.x | tomcat_hardening | on | Tomcat restart | Low; auto-rollback on failed health check |
| WEB-02 | Tomcat AJP connector disabled | 9.x | tomcat_hardening | on | Tomcat restart | Medium if a web server proxies over AJP |
| WEB-10 | HSTS | OWASP headers | haproxy_headers | on | haproxy reload | Low |
| WEB-11 | `X-Content-Type-Options`, `X-Frame-Options` | OWASP headers | haproxy_headers | on | reload | Low |
| WEB-12 | Content-Security-Policy | OWASP headers | haproxy_headers | off | reload | High: a wrong policy breaks the UI |
| WEB-13 | Cookie `Secure` and `HttpOnly` (CSRF cookies excluded) | OWASP session | haproxy_headers | on | reload | Low |
