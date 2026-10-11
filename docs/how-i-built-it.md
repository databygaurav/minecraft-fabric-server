# How I made my Minecraft Fabric server

I moved my existing Aternos world to a Minecraft Java server running on my Windows desktop, then used playit.gg so my friend could join from another house. My setup uses Minecraft 26.3, Fabric Loader 0.19.5, Temurin Java 25, and a 4 GB maximum server heap.

This walkthrough follows my build notes. Suggested reproduction settings are shown explicitly; they are not a claim that every setting or mod is currently installed. At repository preparation, the server had offline authentication, a 20-player limit, view/simulation distances of 10, and an empty server mods folder. Nothing in this guide has been applied automatically to that working server.

## Step 1 — Create the server folder

Create a folder named `Minecraft-Server`. A desktop folder works, but a simple location on an SSD, such as `C:\Minecraft-Server`, makes management easier. Keep the Git repository in a separate directory so the world, credentials and generated files stay private.

## Step 2 — Check Java

Press **Win + R**, enter `cmd`, and run:

```bat
java -version
```

This project uses **Java 25**. Install [Eclipse Temurin JDK 25](https://adoptium.net/temurin/releases/?version=25) if needed and configure `JAVA_HOME` to point to the JDK folder. Reopen the terminal, then check the executable the startup script will actually use:

```bat
"%JAVA_HOME%\bin\java.exe" -version
```

See [Fabric's Java installation guide](https://docs.fabricmc.net/players/installing-java/windows). For other Minecraft versions, check their specific Java requirements rather than assuming all future 26.x versions work with the same Java release. The repository scripts deliberately validate major version 25.

## Step 3 — Install Fabric Server

Open the [official Fabric server download page](https://fabricmc.net/use/server/). Select Minecraft **26.3**, matching the existing world, and Fabric Loader **0.19.5** for this documented setup.

Download the executable server launcher, put it in the server folder, and rename it:

```text
fabric-server.jar
```

The launcher downloads required runtime files on first launch. See the [Fabric installation guide](https://wiki.fabricmc.net/install). Do not commit the launcher or generated libraries to GitHub.

## Step 4 — Allocate 4 GB of server RAM

Inside the server folder, create `start.bat`. Enable file-name extensions in Explorer so it does not become `start.bat.txt`. Open it in Notepad and save:

```bat
@echo off
cd /d "%~dp0"
"%JAVA_HOME%\bin\java.exe" -Xms2G -Xmx4G -jar fabric-server.jar nogui
pause
```

This portable form of my original launcher selects its own directory and uses `JAVA_HOME`. `-Xms2G` sets the initial heap and `-Xmx4G` sets the maximum heap.

Double-click it. The first launch should generate files including `eula.txt`. Read the [Minecraft EULA](https://www.minecraft.net/eula), set `eula=true` yourself if you agree, save, and launch again.

For ongoing management, the repository's [startup script](../scripts/start.ps1) adds Java/JAR checks and duplicate-operation protection. Its [batch wrapper](../scripts/start.bat) is run from the repository with an explicit `-ServerDir`; it is different from the small runtime-local launcher above. Use one launcher at a time.

## Step 5 — Configure the server

Type `stop` in the server console and wait for shutdown before editing `server.properties`. For a new authenticated two-player installation, these are the suggested settings:

```properties
max-players=2
view-distance=8
simulation-distance=6
online-mode=true
white-list=true
enforce-whitelist=true
server-port=25565
difficulty=hard
spawn-protection=0
```

Keep `server-ip=` empty for the ordinary setup. The distances are starting points to measure, not benchmarked optimum values.

My existing TLauncher-oriented setup uses `online-mode=false`. That lets a connecting person claim another player's username; a whitelist cannot authenticate them. Prefer properly authenticated accounts. Switching an existing world to online mode requires planning for UUIDs and player data, so do not blindly copy these settings over the working configuration. Read [security](security.md) first.

## Step 6 — Separate client and server mods

The server does not need every mod from the Minecraft client.

| Mod or content | Install on |
| --- | --- |
| New mobs, blocks or gameplay mechanics | Server and client when the mod requires both |
| Lithium | Server and/or client |
| FerriteCore | Server and/or client |
| Fabric API | Each side where another mod requires it |
| Sodium | Client |
| Iris | Client |
| Shader packs | Client only |

While the server is stopped, put only compatible server mod JARs in `Minecraft-Server\mods`. Check each exact download for Minecraft 26.3, Fabric, loader requirements and dependencies. Do not copy the entire client mods folder. The inspected server mods directory was empty, so this is guidance for adding mods rather than an installed-mod inventory. See [mod sources and compatibility checks](mods.md).

## Step 7 — Transfer the Aternos world

Stop the Aternos server, open its **Worlds** page, select the existing world and download it. Keep an untouched private copy of the ZIP, then extract into a staging folder. See [Aternos support](https://support.aternos.org/) for the current export interface.

1. Stop the local Fabric server and wait for shutdown.
2. Back up its existing world too. Never merge the imported world into a generated world or silently overwrite it.
3. With explicit approval, retain the old local world under a different private name, then copy the complete extracted world folder into the runtime directory.
4. Name the imported folder `world`, or set `level-name` to its name.
5. Verify `world\level.dat` exists directly at that level, rather than under an extra nested `world` directory.
6. Start and test privately before reopening remote access.

Preserve all world contents, including dimensions, player data, advancements and statistics. Buildings, inventories and progress should carry over when game/mod versions and player identities are compatible. Online/offline UUID differences can make inventories appear missing. See [world migration](world-migration.md) before changing identities or renaming player files.

## Step 8 — Connect locally

Start the server. Because the whitelist is enabled, add your intended player name in the server console before joining:

```text
whitelist add YourMinecraftUsername
```

Open Minecraft with the compatible client setup, choose **Multiplayer → Direct Connection**, and enter:

```text
localhost:25565
```

Successful local play verifies this connection path before introducing the tunnel. `localhost` works only on the computer hosting the server.

## Step 9 — Connect a friend from another house

Use the official [playit.gg agent](https://playit.gg/) and [support instructions](https://playit.gg/support/):

1. Download and launch the Windows agent.
2. Follow its browser instructions to register or claim the agent privately.
3. Create a Minecraft Java tunnel.
4. Set its local target to `127.0.0.1`, port `25565`, when the agent runs on the server computer.
5. Add your friend's intended identity to the whitelist through the server console.
6. Share the assigned server endpoint privately with your friend, including the assigned external port if required.

Keep both the Minecraft server and agent running. The tunnel provides remote connectivity without traditional router port forwarding, but does not authenticate Minecraft usernames. Keep agent tokens, claim links and actual tunnel addresses out of this repository. See [networking](networking.md) for connection failures and DNS checks.

## Step 10 — Whitelist both players; keep administration limited

In the server console, with the correct names substituted:

```text
whitelist add YourMinecraftUsername
whitelist add FriendsMinecraftUsername
whitelist on
```

Ordinary survival play does not need OP. The original notes included this optional console command for in-game administration:

```text
op YourMinecraftUsername
```

Only consider it after the intended player's identity is securely authenticated. On an unprotected offline-mode server, someone impersonating that name may inherit operator permissions. Using the local server console for administration avoids needing a player operator for routine management.

Granting yourself OP does **not** remove any existing operators. Review existing operator permissions privately and, when appropriate, revoke each unwanted operator through the console with `deop <name>`. This repository never grants or revokes permissions automatically.

My next maintenance steps are regular [verified backups](backup-restore.md) and measuring [tick performance versus network jitter](performance.md) when rubberbanding occurs.
