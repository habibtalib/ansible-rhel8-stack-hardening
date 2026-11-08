# Testing and rollout

## Order

1. **Baseline (read-only).** Record service state, listening ports, DB sessions, replication lag and application health on every target. Keep it for comparison.
2. **Audit.** `ansible-playbook -i <inv> playbooks/00_audit.yml`. Read the diff for every host.
3. **Testbed.** Apply each playbook on a test system that matches production (same OS minor, same DB versions, same application release). Turn on one risky toggle at a time.
4. **Reboot the testbed.** Many changes (modules, sysctl, sqlnet, passwordcheck) only show their effect after a restart. Check the application end to end after the reboot: send a real transaction through, not just a health URL.
5. **Production, one node at a time.** Use `--limit <host>`, standbys and replicas first, primary or leader last. Give notice to whoever monitors the service before any restart.
6. **Verify.** `playbooks/04_verify.yml`, then compare with the baseline.
7. **Record.** Keep the `scripts/run.sh` logs. Write down what changed, where, when, and the rollback used if any.

## Stop rules

Stop and roll back if any of these happens after a change:

- a service that was active is not active, or restarts in a loop;
- DB sessions for the application drop below the baseline and do not recover;
- replication or Data Guard lag does not return to the baseline;
- the application health check or an end-to-end transaction fails.

## Rollback

- Files: `ansible-playbook playbooks/99_rollback.yml --limit <host> -e rollback_confirm=true` restores the `.before-hardening` copies; add timestamped `~` backups to `rollback_extra_files`.
- pg_hba.conf and Tomcat roll back automatically when their checks fail.
- Database statements: printed by `99_rollback.yml`; run them by hand after review.
- Restart or reload the affected service in the same window.

## Notes per area

- **Oracle with Data Guard:** sqlnet.ora is per host; apply on the standby first, then the primary. DDL (profile, audit, revoke) only on the primary. Check redo transport (`v$archive_dest_status`) after a sqlnet change.
- **Patroni:** parameters live in the DCS; run against the leader. For `shared_preload_libraries`, restart replicas one by one, then switch over and restart the old leader.
- **Docker hosts:** never apply IPv4 forwarding off; leave container volume data out of ownership fixes.
- **HAProxy:** set `haproxy_frontend_name` to the real frontend; check the UI after enabling CSP.
