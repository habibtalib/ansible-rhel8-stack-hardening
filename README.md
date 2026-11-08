# ansible-rhel8-stack-hardening

Ansible roles that close common penetration-test and CIS findings on a RHEL 8 application stack with Oracle 19c, PostgreSQL (standalone or Patroni), MySQL and MongoDB in Docker, Tomcat and HAProxy.

Every control was first run as a one-off script on a test system that matches production, then on production, one node at a time. These roles are the generic, reusable form of those scripts.

## Principle: human in the loop

AI agents can draft playbooks quickly. They can also be confidently wrong about the system they run on. This kit assumes a loop:

1. **AI drafts.** An agent writes or changes a role from the finding and the vendor documentation.
2. **Human reviews.** A person reads the diff, the defaults and the rollback before anything runs.
3. **Check mode first.** `playbooks/00_audit.yml` (or `scripts/run.sh` without `--apply`) shows what would change. Nothing is written.
4. **Apply on the testbed, then one production node at a time.** Risky controls are off by default and need a per-host toggle. Restarts need `allow_restart: true`.
5. **Verify and report.** `playbooks/04_verify.yml` checks the live state. Keep the log from `scripts/run.sh` as the record.

## Quick start

```bash
cp inventories/example.ini inventories/lab.ini      # your hosts; git-ignored
ansible-playbook -i inventories/lab.ini playbooks/00_audit.yml
```

```bash
scripts/run.sh playbooks/01_os.yml inventories/lab.ini              # check mode + diff
```

```bash
scripts/run.sh playbooks/01_os.yml inventories/lab.ini --apply --limit host1
```

```bash
ansible-playbook -i inventories/lab.ini playbooks/04_verify.yml
```

Requirements: ansible-core 2.15+, collections `ansible.posix` and `community.general`. Targets: RHEL 8 or a rebuild, Python 3, sudo.

## Layout

| Path | What |
|---|---|
| `group_vars/all.yml` | Global switches: `allow_restart` (default false), `docker_host` |
| `roles/os_hardening` | Kernel modules, sysctl, gpgcheck, unused services, at/cron, password quality and ageing, SSH DenyUsers, rsyslog, journal-remote, unowned files, ICMP timestamp |
| `roles/oracle_hardening` | sqlnet.ora encryption and integrity, weak certificates, password verify function, unified audit, ANY/PUBLIC synonym privileges |
| `roles/postgresql_hardening` | Logging, TLS, passwordcheck, removal of local `trust` from pg_hba.conf with auto-rollback; Patroni-aware |
| `roles/mysql_hardening` | `validate_password` component in a MySQL container |
| `roles/mongodb_checks` | Reports auth and port exposure; tightens data-directory mode |
| `roles/tomcat_hardening` | Error page without version or stack trace, AJP connector off, auto-rollback |
| `roles/haproxy_headers` | HSTS, nosniff, frame options, optional CSP, cookie flags inside the existing frontend |
| `playbooks/00_audit.yml` | Check mode for every role |
| `playbooks/01_os.yml` … `03_database.yml` | Apply, `serial: 1` |
| `playbooks/04_verify.yml` | Read-only assertions |
| `playbooks/99_rollback.yml` | Restore backed-up files; prints DB undo statements |
| `docs/CONTROLS.md` | Control → CIS reference → task → risk |
| `docs/EXCEPTIONS.md` | Findings to document instead of fix, with reasons |
| `docs/TESTING.md` | Test and rollout procedure |

## Safety defaults

- Config files change; services do not restart unless `allow_restart: true`.
- Every edited file is backed up (`backup: true` or `<file>.before-hardening`).
- SCTP is never blacklisted by default. IPv4 forwarding stays on where `docker_host: true`.
- `rpcbind` is only disabled where `rpcbind_disable: true`; service and socket are masked.
- Unowned-file fixes touch only the paths you list; the root filesystem is never walked.
- HAProxy headers go inside your existing frontend; the file is validated with `haproxy -c` before it is written.
- `HttpOnly` is not added to cookies that page scripts read (`XSRF-TOKEN`, `CSRF-TOKEN`).
- Oracle DDL runs on the Data Guard primary only. PostgreSQL parameters go to the Patroni DCS from the leader.
- pg_hba.conf is checked with `pg_hba_file_rules` before reload and restored if parsing or local login fails.
- Passwords come only from ansible-vault variables (for example `vault_mysql_root_password`).

## Contributing

Open a pull request with: the finding, the CIS reference, the change, how it was tested (testbed output), and the rollback. Keep host names, addresses and organisation names out of the repo.

## Credits

Written and reviewed by a small infrastructure team: AI drafts each change, an engineer reviews it, it runs in check mode on a testbed, then on production one node at a time.

## License

MIT. See `LICENSE`.
