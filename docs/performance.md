# Performance and rubberbanding

The host has 16 GB physical RAM. Server `-Xmx4G` plus a 6 GB client heap leaves roughly 6 GB for Windows and other work, but heaps are not total process memory: JVM native allocations, graphics drivers and caches need additional space. Watch Windows memory pressure and paging. The RTX 4060 mainly benefits the client/shaders; it does not accelerate dedicated-server world ticks.

Keep the measured baseline at 2 GB initial / 4 GB maximum server heap and default Java 25 GC ergonomics. Do not add unsupported tuning flags or increase heaps merely because movement snaps. The scripts allow configurable memory but cannot guarantee the requested amount is affordable.

The inspected server uses view-distance 10 and simulation-distance 10. For this two-player host, the example proposes 8 and 6 as starting points to test, not a measured optimum. Lower simulation distance reduces ticking work; lower view distance reduces chunk work and traffic. Change one setting at a time while stopped, then compare equivalent workloads. Exploring new terrain, farms and large entity counts can produce very different results.

At the normal 20 TPS target, a tick has a 50 ms budget. Sustained MSPT over 50 means the server cannot maintain 20 TPS; spikes may cause noticeable pauses even when an average looks acceptable. Observe both tick performance and remote latency during rubberbanding. Compare host-local play, remote play, stationary play and fresh chunk exploration.

For profiling, first confirm an exact Fabric 26.3-compatible release of [spark](https://spark.lucko.me/) before installation; compatibility has not been validated here. Its [command documentation](https://spark.lucko.me/docs/Command-Usage) describes `spark tps`, `spark health show`, and `spark profiler start`. Run a short capture during the issue, then `spark profiler stop --save-to-file` for local output. In the server console omit the leading slash. Review profiles privately; default upload/viewer commands can disclose system and server details.

If local ticks remain healthy but remote players snap back, investigate Wi-Fi, upload saturation, jitter and relay routing. ICMP ping may be blocked or differ from game traffic, so use multiple observations. If both players lag and MSPT rises, inspect chunk generation, entities, CPU contention, GC and disk activity. If only FPS drops, reduce shader/render settings on the client. Record measurements before calling any change an improvement.
