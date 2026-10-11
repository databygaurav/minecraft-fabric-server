# Moving an Aternos world

The owner already completed this migration and reports preserved progress. These instructions document the process for another installation, not permission to repeat it on the live world.

1. Stop the Aternos server, then use its Worlds page to download the complete world. Keep the original export privately as a recovery copy. Consult [Aternos support](https://support.aternos.org/) for the current Worlds export interface.
2. Record the source Minecraft version, loader, required content mods and authentication mode. Use compatible versions on the destination; never test a downgrade on your only copy.
3. Stop the destination gracefully. Disable automatic restarts and close clients. Back up the destination world before replacing anything.
4. Extract the download into a separate staging directory. Locate the folder containing `level.dat`; do not accidentally nest it as `world\world`. Inspect the archive before extraction and do not execute included files.
5. Preserve the entire world: `region`, dimension data such as `DIM-1` and `DIM1`, `entities`, `poi`, `data`, `datapacks`, `playerdata`, `advancements`, and `stats`, when present. Copying only region files loses other state. Retain custom dimensions and mod-specific data too.
6. With explicit operator approval, rename the destination world to a private rollback directory and copy the staged world to the folder named by `level-name`. Keep source exports and rollback copies until verification is complete.
7. Test privately, with the tunnel disabled: both inventories and ender chests, position, builds, Nether/End, advancements and modded content. Stop and investigate missing data; do not overwrite old player files with newly generated ones.

Player state is keyed by UUID. Online and offline identities can have different UUIDs; name spelling and some authentication mods also affect identity. Switching modes can look like inventory loss even when old files still exist. Record the mapping privately and use a separately backed-up, tested migration procedure. Do not blindly rename UUID files or publish UUIDs/whitelists.
