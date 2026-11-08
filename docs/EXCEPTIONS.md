# Exceptions

Some findings cannot be fixed without breaking the service, need a vendor change, or are not available in the delivered product. Document them instead of forcing a fix. For each one, write the fact **from your own system** (a dated read-only check), the reason, and the compensating control. Do not copy reasons from another site without checking them.

## Template

| Finding | Fact on this system (date, command) | Reason | Compensating control | Review date |
|---|---|---|---|---|
| | | | | |

## Common cases

| Finding | Typical reason | Typical compensating control |
|---|---|---|
| SCTP module should be disabled | Telecom signalling (for example SBc-AP between a broadcast centre and the core network) runs over SCTP. Disabling it stops the service | Keep SCTP only on the hosts with SCTP peers; blacklist it elsewhere |
| IPv4 forwarding should be off | Docker publishes container ports through forwarding and NAT | Only Docker hosts keep it on; their ports are reachable from the management network only |
| `REMOTE_LOGIN_PASSWORDFILE=NONE` | Oracle Data Guard redo transport and remote SYSDBA logins authenticate with the password file | Password file in 12.2 format; failed logons audited |
| Password lifetime / inactivity on DB service accounts | Expiry or lock of an application or replication account stops the service | Strong verify function; credentials stored with restrictive file modes; rotation by procedure |
| `FAILED_LOGIN_ATTEMPTS` ≤ 5 | A lockout of the application account during a reconnect storm stops the service | Failed logons audited; listener reachable from application hosts only |
| MongoDB auditing | Auditing is a MongoDB Enterprise feature; Community images do not have it | Port not published to the host; container network only |
| MongoDB authentication / TLS | Clients inside the vendor's containers would need reconfiguring | As above; vendor change requested |
| MySQL password expiry / `require_secure_transport` in a container | Expiring internal accounts or forcing TLS breaks the application's own connections | Port not published; validate_password on |
| PostgreSQL pgAudit / set_user | Extension not shipped with the vendor database build | Connection and DDL logging on |
| Per-role connection limits | One application role uses most connections; a limit starves it at peak | `max_connections` caps the total |
| WAL archiving | Recovery relies on streaming replicas and backups; archiving needs storage sizing | Two replicas per cluster; replication lag monitored |
| `/tmp` separate partition | Repartitioning the root volume of a live VM needs downtime | Fix at the next rebuild |
| Crypto policy without SHA-1 | System-wide; affects every TLS and SSH peer, untested with external peers | TLS 1.2+ enforced where TLS is used |
| firewalld enabled | Host uses iptables, or Docker manages its own rules; enabling firewalld drops them | Host filtering with iptables; documented rule set |
| `gpgcheck` on a local vendor repo | Vendor RPMs are not signed | Checksums verified at copy; signed OS repos keep `gpgcheck=1` |
| Content-Security-Policy | Application sets headers in code; a proxy policy needs testing against every page | HSTS, nosniff, frame options and secure cookies sent |
| World-writable application folders | Paths required by the vendor's container layout | Parent directory root-owned; data folders tightened where possible |
| Two contradictory findings (e.g. "set X" and "unset X") | Both cannot pass | Keep the stricter value and explain |
