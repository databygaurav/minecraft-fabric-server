# Troubleshooting

| Symptom | Check and next action |
| --- | --- |
| JAVA_HOME missing / wrong major | Reopen terminal after configuring JDK 25; run the exact JAVA_HOME executable |
| Missing server JAR | Place official Fabric launcher at the explicitly selected runtime path as fabric-server.jar |
| Java already running | Gracefully stop server and close client; never kill Java just to bypass the guard |
| Management lock unavailable | Another repository operation may be active; a leftover filename alone is harmless because the OS handle provides the lock |
| World session lock unavailable | Wait for clean shutdown; do not delete session.lock to bypass a running server |
| Server exits immediately | Inspect private logs for EULA, port collision, incompatible Java/mods or missing dependencies |
| Address already in use | Inspect local listeners/processes; check another server instance before restarting |
| Mod dependency failure | Match exact game version, loader, API and other dependency versions; remove the new change from an isolated test setup |
| Connection refused / timeout | Test localhost, then agent target and assigned tunnel port, then scoped firewall rules |
| Unknown host | Check tunnel spelling and DNS resolution; do not publish the real hostname in a bug report |
| Not whitelisted | Verify name and authenticated identity via console; do not turn whitelist off |
| Missing inventory after migration | Stop; preserve playerdata and verify UUID/authentication mode rather than generating more replacement state |
| Rubberbanding | Compare localhost and remote alongside TPS/MSPT; separate network jitter from tick lag |
| Low FPS with healthy TPS | Reduce client shader/render load; server heap changes rarely solve rendering bottlenecks |
| Backup integrity failure | Leave partial snapshot untouched, check free space/disk errors and concurrent writers; make a new clean backup |
| Restore interrupted | Keep Java stopped, inspect retained rollback/staging directories, recover deliberately before restarting |
| Script execution blocked | Follow local execution policy; review and unblock downloaded files where permitted |

When asking for help, share versions and redacted error excerpts. Logs often include player identifiers, IPs, paths or tunnel information; never upload them unreviewed.
