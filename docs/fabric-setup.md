# Fabric setup

Use the [official server launcher page](https://fabricmc.net/use/server/), selecting Minecraft **26.3** and Fabric Loader **0.19.5**. Record the launcher version and download source in private maintenance notes. Rename the downloaded executable server launcher to `fabric-server.jar` in an empty runtime directory. The launcher fetches its libraries on first use; Internet access is required.

The existing `.fabric/server` filenames and Fabric library directory indicate Minecraft 26.3 and Loader 0.19.5. This is file-based evidence, not a new startup test. See [Fabric's 26.3 release notes](https://www.fabricmc.net/2026/09/15/263.html) and [installation wiki](https://wiki.fabricmc.net/install).

Run the [installation workflow](installation.md) to handle the EULA, properties, and whitelist. Never commit the launcher, generated libraries or game JARs. Do not replace a running JAR. For upgrades, stop, back up, test an isolated copy, then update deliberately; loading a world in a newer game version can make downgrade unsafe.
