# How I made my Minecraft server

I wanted to play Minecraft with my friend using our old Aternos world. I moved the world to my Windows PC and used **playit.gg** so my friend could join from another house.

My setup: **Minecraft 26.3 · Fabric 0.19.5 · Java 25 · 4 GB server RAM · 2 players**.

These are the steps I followed, with safer settings for anyone making a new server. My working server is already set up; it does not need to be rebuilt.

## 1. Create a folder

Create a folder called `Minecraft-Server` on your C: drive:

```text
C:\Minecraft-Server
```

This is where the actual server files go. Keep this GitHub project in a separate folder.

## 2. Install Java 25

Install [Eclipse Temurin JDK 25](https://adoptium.net/temurin/releases/?version=25). Set `JAVA_HOME` to the Java installation folder — [help with this step](docs/java-setup.md).

Open Command Prompt and check:

```bat
"%JAVA_HOME%\bin\java.exe" -version
```

It should show Java 25.

## 3. Download Fabric

Open the [Fabric server download page](https://fabricmc.net/use/server/).

Choose Minecraft **26.3** and Fabric Loader **0.19.5**. Download the server JAR, move it into your server folder, and rename it `fabric-server.jar`.

## 4. Make the start button

Inside your server folder, create a file named `start.bat`. Make sure its name is not `start.bat.txt`.

Open it in Notepad and paste:

```bat
@echo off
cd /d "%~dp0"
"%JAVA_HOME%\bin\java.exe" -Xms2G -Xmx4G -jar fabric-server.jar nogui
pause
```

Save and double-click it. This lets the server use up to **4 GB RAM**.

On the first run, it creates `eula.txt`. Read the [Minecraft EULA](https://www.minecraft.net/eula). If you agree, change the line to `eula=true`, save, and run `start.bat` again.

## 5. Choose the settings

Type `stop` in the server window and wait for it to finish. Open `server.properties`.

For a **new server using authenticated Minecraft accounts**, use:

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

My existing server uses `online-mode=false`. In that mode, someone can pretend to be another player, even with a whitelist. Changing an existing server's login mode can also affect inventories. Read [the security guide](docs/security.md) before changing it.

## 6. Add mods only where needed

| Mod | Where it goes |
| --- | --- |
| Sodium, Iris, shader packs | Your Minecraft client |
| Lithium, FerriteCore | Can be used on the server |
| Fabric API | Wherever another mod requires it |
| Mods adding blocks or mobs | Often both client and server; check the mod's instructions |

Stop the server before adding server mods to its `mods` folder. Each download must support **Minecraft 26.3 and Fabric**. My server's mods folder was empty when checked; these are optional additions.

## 7. Bring over the Aternos world

1. Stop your Aternos server and download the world from its **Worlds** page.
2. Keep a backup of that download.
3. Stop your local server. Back up its existing world and keep it separately.
4. Extract the downloaded world into the server folder as `world`. Do not merge it with the old folder.
5. Check that `C:\Minecraft-Server\world\level.dat` exists.

Keep the whole world folder. Matching game versions, mods and player identities helps preserve builds and inventories. [More help moving a world](docs/world-migration.md).

## 8. Join your server

Run `start.bat`. In the server window, enter this with your actual player name:

```text
whitelist add YourMinecraftUsername
```

In Minecraft, open **Multiplayer → Direct Connection** and enter:

```text
localhost:25565
```

This address works on the PC running the server.

## 9. Let your friend join

**[Full playit.gg setup guide](docs/playit-setup.md)** — follow this if you are setting it up for the first time.

Download and open [playit.gg](https://playit.gg/). Follow its sign-in instructions and create a **Minecraft Java tunnel** pointing to:

```text
Local address: 127.0.0.1
Local port:    25565
```

In the server window, add your friend:

```text
whitelist add FriendsMinecraftUsername
```

Send your friend the address playit gives you, including its port if shown. Keep both the server and playit running. Keep that address and your playit account details private.

## 10. Play, stop and back up

For normal play, neither player needs OP. Use the server window for admin commands. Giving OP to a name on an unprotected offline-mode server is risky because someone else can claim that name.

When finished, type:

```text
stop
```

Wait for shutdown. Then copy the whole `world` folder to a separate backup folder with the date in its name. Keep backups outside this GitHub project.

## What I open each time I play

1. My existing `C:\Minecraft-Server\start.bat`.
2. The playit.gg app.
3. Minecraft, then connect to `localhost:25565`.

## Optional extras

**You can follow this guide without using the PowerShell scripts in this repository.** They add checks and backup tools for later.

- [Something is not working](docs/troubleshooting.md)
- [Backup and restore tools](docs/backup-restore.md)
- [Technical details and script instructions](docs/advanced.md)

This repository shares the instructions and tools. My actual world, player files, downloaded JARs and private settings stay on my PC.

Original scripts and documentation use the [MIT license](LICENSE). Not affiliated with Mojang or Microsoft.
