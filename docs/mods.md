# Mods and shader packs

Inspection found no JARs in the server `mods` directory. The owner's shader/performance setup is client-side or otherwise unverified; this repository does not claim these mods are installed on the server.

| Project | Installation role | Purpose |
| --- | --- | --- |
| [Sodium](https://modrinth.com/mod/sodium) | Client | Rendering performance |
| [Iris](https://modrinth.com/mod/iris) | Client | Shader support; select its compatible Sodium release |
| [Lithium](https://modrinth.com/mod/lithium) | Server and/or client | Game logic optimizations |
| [FerriteCore](https://modrinth.com/mod/ferrite-core) | Server and/or client | Memory optimizations |
| [Fabric API](https://modrinth.com/mod/fabric-api) | Wherever a selected mod requires it | Shared mod APIs; not a performance tweak by itself |
| Shader packs | Client shaderpacks directory | Visual effects and GPU workload |

The publisher listings were checked on 2026-10-11. Lithium and FerriteCore list Minecraft 26.3 and Fabric, making them candidates for this server. No exact release set has been installed or integration-tested here. Before installing **any** mod, filter the publisher's Versions page for exactly Minecraft 26.3 and Fabric, read that file's dependencies and minimum loader version, and verify the environment. A project's general compatibility list is not proof that every file works. Defer installation if an exact compatible release cannot be confirmed.

Keep a private manifest of exact filenames, versions, source URLs and SHA-256 hashes. Back up, stop, add one change, and test a separate world copy. Content mods may be required on both sides; missing content mods can damage a modded world. Fabric does not run Bukkit/Spigot plugins by simply putting them in `mods`.

Do not put Sodium, Iris or shader packs into the dedicated server. Shaders consume the client's GPU budget; they do not improve server TPS. Do not redistribute downloaded binaries in this repository.
