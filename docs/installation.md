# Installation on another Windows computer

1. Install Git and [Temurin JDK 25](https://adoptium.net/temurin/releases/?version=25). Follow [Java setup](java-setup.md), then open a fresh PowerShell window.
2. Clone this repository into a tools/projects directory. Create a separate, empty runtime directory such as `C:\Minecraft-Server-New`. Do not initialize Git inside the runtime.
3. Follow [Fabric setup](fabric-setup.md) for Minecraft 26.3 / Loader 0.19.5. Place the downloaded launcher there as `fabric-server.jar`.
4. Run the launcher once from the new directory: `& "$env:JAVA_HOME\bin\java.exe" -Xms2G -Xmx4G -jar .\fabric-server.jar nogui`. It may download dependencies and generate files. Read [Minecraft's EULA](https://www.minecraft.net/eula), then set `eula=true` yourself only if you agree.
5. While stopped, review the generated properties and the repository example. For this new installation only, copy the example as `server.properties` if appropriate. It requires authenticated accounts. Do not copy it over an existing offline-mode world without planning player identity migration.
6. Start with `scripts\start.ps1 -ServerDir 'C:\Minecraft-Server-New'`. Add the two authenticated player names using `whitelist add <name>` in the console. No OP is needed for normal play.
7. Connect locally first. Stop cleanly before [importing a world](world-migration.md) or changing mods.
8. Set up the [tunnel](networking.md) after local play and authentication work. Test from the other house.
9. Make and verify a private backup before updating Minecraft, Java, Fabric or mods. Record exact versions in private maintenance notes; test upgrades on a separate copy, with the public tunnel disabled.

The current working server is already installed. These steps are for reproduction and must not be repeated over it.
