# Networking

New to playit? Start with the [simple setup guide](playit-setup.md).

On the host, connect to `localhost:25565`. For another machine on the same LAN, use the host's private LAN address and an appropriately scoped Windows Firewall rule if required. Keep actual addresses private. Leave `server-ip=` empty unless you understand a specific binding requirement.

For the remote friend, use [playit.gg's official agent and support](https://playit.gg/support/). Sign in and claim the agent privately. Create a Minecraft Java/TCP tunnel targeting `127.0.0.1:25565` when the agent runs on the server host. Keep both the agent and server running, then share the assigned endpoint privately. Use the assigned external port when required; it may differ from 25565. Test from the other house after localhost succeeds.

The tunnel normally avoids direct router port forwarding. Do not add Internet-facing RCON or broad firewall exceptions. A relay does not authenticate players and is not an anti-cheat layer. Keep agent credentials, claim links, screenshots and real endpoints out of commits and issues.

Private diagnostics (replace example placeholders locally):

```powershell
Test-NetConnection localhost -Port 25565
Resolve-DnsName 'your-private-tunnel-hostname'
Test-NetConnection 'your-private-tunnel-hostname' -Port 12345 # assigned external port
```

DNS failure: verify the exact assigned hostname, agent/dashboard status and resolver connectivity. DNS success alone does not mean the game port is reachable. Connection refused: check Java is listening, then tunnel target and assigned port. Timeout: check agent connectivity and firewall scope. Whitelist rejection: verify the exact name and identity mode, then add the intended player through the console; do not disable the whitelist to diagnose.

Offline and online UUIDs differ. An authentication-mode change may break whitelist matching or make inventory appear missing; preserve data and consult [migration](world-migration.md). For rubberbanding, compare localhost with remote play during the same workload. Healthy local ticks plus remote-only movement snaps suggests the network/relay path; symptoms alone do not prove the cause.
