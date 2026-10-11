# How to set up and use playit.gg

playit.gg lets your friend connect to the Minecraft server on your PC from another house. Your PC still runs the server; playit provides the connection.

**Only the person hosting the server needs the playit app.** Your friend joins through Minecraft. See [playit's official site](https://playit.gg/).

## 1. Check your Minecraft server first

Double-click your existing `C:\Minecraft-Server\start.bat` and wait for the server to finish starting.

On that same PC, open Minecraft → **Multiplayer → Direct Connection** and enter:

```text
localhost:25565
```

If you cannot join locally, fix that first. playit cannot connect players to a server that is not running.

## 2. Download and open playit

1. Go to the [official playit website](https://playit.gg/download).
2. Choose the Windows download through its setup flow.
3. Open the downloaded app on the **same PC as your Minecraft server**.
4. Follow the browser link or instructions it gives you.
5. Create an account or sign in, then connect the app to your account.

The app may call this **claiming an agent**. An agent simply means the playit app running on your PC. Keep its claim link and account details private.

## 3. Create a Minecraft tunnel

In the playit dashboard, open the tunnels area and choose the option to add a tunnel. Button names may change; the setup wizard will guide you.

Select your connected agent and use:

| Setting | Value |
| --- | --- |
| Tunnel type | Minecraft Java |
| Local address / Local IP | `127.0.0.1` |
| Local port | `25565` |

Save or create the tunnel. The local port must match `server-port` in your server's `server.properties` file.

**Why can everyone use the same numbers?**

`127.0.0.1` means **this computer**. On your PC it points to your server. On your friend's PC it points to theirs. Hundreds of people can use `127.0.0.1:25565` on separate computers without a conflict.

Each tunnel has its own public address/port combination. That tells playit which server a player wants to reach.

These settings assume the playit app and server are on the same PC. If they are on separate PCs, the local address must point to the server PC instead. Two servers on one PC normally need different local ports.

## 4. Add your friend to the whitelist

In the **Minecraft server window**, type this with your friend's actual Minecraft name:

```text
whitelist add FriendsMinecraftUsername
```

Your friend does not need OP to play.

## 5. Give your friend the public address

Open your tunnel in the playit dashboard and copy the assigned Minecraft connection address. Include its port if shown.

Send that address privately to your friend. They open Minecraft → **Multiplayer → Add Server** or **Direct Connection**, paste it into **Server Address**, and join.

| Who is joining? | Address to use |
| --- | --- |
| You, on the server PC | `localhost:25565` |
| Your friend in another house | The public connection address shown by playit |

**Do not send your friend `127.0.0.1`.** On their PC, that points back to their own computer.

## Each time you want to play

1. Start your Minecraft server with `start.bat`.
2. Open playit and check that the agent is connected.
3. Keep your PC awake and both programs running.
4. Join locally; your friend joins using the playit address.

You normally reuse the existing tunnel; you do not need to create a new one each session. If you recreate it or change its address, give your friend the updated address.

When finished, type `stop` in the Minecraft server window and wait for shutdown. You can then close playit. Closing playit while people are playing cuts off their remote connection.

## If your friend cannot join

| Problem | Check first |
| --- | --- |
| Cannot join using localhost | Is Minecraft's server running and fully started? |
| Connection refused | Does the tunnel point to `127.0.0.1` and the port in `server.properties`? |
| Connection timed out | Is the playit agent connected, and is your PC awake and online? |
| Unknown host | Copy the assigned address again and check for typing mistakes. |
| Not whitelisted | Add the correct Minecraft username in the server console. |
| Version or mod error | Both players need a compatible Minecraft version and any required client mods. |

For more help, use [playit's support pages](https://playit.gg/support/) or this project's [networking guide](networking.md). Do not disable your whole firewall to troubleshoot.

## One important safety note

playit provides access to your server; it does not verify Minecraft player identities. With `online-mode=false`, someone may pretend to be a whitelisted player. Removing OP limits their admin access but does not solve impersonation. See [account security](security.md).

Keep playit passwords, tokens and claim links out of GitHub. Share your server address only with the people you want to invite.
