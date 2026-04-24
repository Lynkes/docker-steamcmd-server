# Per-game profile hooks

Files here are named by **Steam App ID** and are picked up automatically when you
set `GAME_ID` to the matching value.

## How it works

1. Drop a file from this directory into `/opt/custom/` on a host-mounted volume:

   ```bash
   --volume /path/to/custom:/opt/custom
   ```

2. Set `GAME_ID` to the matching App ID:

   ```bash
   --env GAME_ID=2394010   # Palworld example
   ```

3. On startup, `start.sh` runs `/opt/custom/${GAME_ID}.sh` automatically —
   installing any extra packages the game needs.

4. `start-server.sh` also auto-sets `GAME_LAUNCH_CMD` and any required environment
   variables for the App ID, so you don't have to set them manually.

The hook runs as **root** before the server starts, so `apt-get` works without `sudo`.
Set `GAME_LAUNCH_CMD` explicitly via `--env` at any time to override the auto-detected value.

---

## Games covered

### Native Linux servers

| File | App ID | Game | Extra packages | Auto GAME_LAUNCH_CMD |
|------|--------|------|----------------|----------------------|
| [380870.sh](380870.sh) | 380870 | Project Zomboid | _(none — uses bundled JRE)_ | `./ProjectZomboid64` |
| [2394010.sh](2394010.sh) | 2394010 | Palworld | `lib32stdc++6 xdg-user-dirs` | `./PalServer.sh` |
| [258550.sh](258550.sh) | 258550 | Rust | `libsqlite3-0 libgdiplus unzip` | `./RustDedicated` |
| [1690800.sh](1690800.sh) | 1690800 | Satisfactory | `xdg-user-dirs` | `./FactoryServer.sh` |
| [233780.sh](233780.sh) | 233780 | Arma 3 ¹ | `lib32stdc++6` | `./arma3server_x64` |
| [629800.sh](629800.sh) | 629800 | Mordhau | Many X11/GUI libs | `./MordhauServer.sh` |
| [232130.sh](232130.sh) | 232130 | Killing Floor 2 | `curl` | `./Binaries/Win64/KFGameSteamServer.bin.x86_64` |
| [1621690.sh](1621690.sh) | 1621690 | Core Keeper | `lib32stdc++6 xvfb screen libxi6` | `./CoreKeeperServer` |
| [1948160.sh](1948160.sh) | 1948160 | Euro Truck Simulator 2 | `lib32stdc++6 libatomic1 libx11-6` + tarball | `./bin/linux_x64/eurotrucks2_server` |
| [2239530.sh](2239530.sh) | 2239530 | American Truck Simulator | `lib32stdc++6 libatomic1 libx11-6` + tarball | `./bin/linux_x64/amtrucks_server` |
| [1042420.sh](1042420.sh) | 1042420 | DayZ ¹ | `lib32stdc++6 libcurl4 libcap2` | `./DayZServer_x64` |

¹ Requires a Steam account that owns the game — set `USERNAME` + `PASSWRD`.

---

### Wine-based servers (Windows-only binaries)

The following games have **no native Linux server binary**. They run the Windows
executable under Wine. Two things are required beyond the profile hook:

1. **SteamCMD must download the Windows build.** Add
   `+@sSteamCmdForcePlatformType windows` to the `steamcmd` calls in
   `start-server.sh`, or bake it into a derived image.

2. **Wine install overhead.** The hooks guard with `dpkg -s winehq-stable` so
   `docker restart` skips the install entirely (packages are already in the
   container's writable layer). For `docker rm` + `docker run` (container
   recreation), mount `/var/cache/apt/archives` to a host directory so downloaded
   `.deb` files persist — `apt-get` will extract from disk instead of re-downloading:

   ```bash
   --volume /path/to/apt-cache:/var/cache/apt/archives
   ```

   For production, bake Wine into a derived `Dockerfile` instead (zero overhead):

   ```dockerfile
   FROM your-steamcmd-image
   RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
           winehq-stable winbind xvfb \
    && rm -rf /var/lib/apt/lists/*
   ```

`WINEARCH` and `WINEPREFIX` are set automatically by `start-server.sh` when these
App IDs are detected (defaults: `win64` / `${SERVER_DIR}/WINE64`).

| File | App ID | Game | Auto GAME_LAUNCH_CMD |
|------|--------|------|----------------------|
| [1604030.sh](1604030.sh) | 1604030 | V Rising | `xvfb-run … wine64 ./VRisingServer.exe` |
| [2430930.sh](2430930.sh) | 2430930 | ARK: Survival Ascended | `xvfb-run … wine64 ./ArkAscendedServer.exe` |
| [728470.sh](728470.sh) | 728470 | Astroneer | `xvfb-run … wine64 ./AstroServer.exe` |
| [443030.sh](443030.sh) | 443030 | Conan Exiles | `xvfb-run … wine64 ./ConanSandboxServer.exe` |
| [1326470.sh](1326470.sh) | 1326470 | Sons of The Forest | `xvfb-run … wine64 ./SonsOfTheForestDS.exe` |
| [556450.sh](556450.sh) | 556450 | The Forest | `xvfb-run … wine64 ./TheForestDedicatedServer.exe` |
