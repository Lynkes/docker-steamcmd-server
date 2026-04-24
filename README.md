# SteamCMD Universal Docker

A lightweight, game-agnostic SteamCMD Docker image based on `debian:bookworm-slim`.  
Install and run **any** Steam dedicated server by setting a handful of environment variables — no image rebuild required.

For games listed in [scripts/games/](scripts/games/), just set `GAME_ID` — the image auto-downloads the correct game profile, sets `GAME_LAUNCH_CMD`, installs runtime dependencies, and configures environment variables automatically.

**Update Notice:** Restart the container to update the game to the latest version.

## Volumes

| Container path | Purpose |
|----------------|---------|
| `/opt/steamcmd` | SteamCMD installation — mount to persist across container recreations |
| `/serverdata` | Game server files — always mount a host directory here |
| `/opt/custom` | _(optional)_ Custom hook scripts — see [Hooks](#hooks) |
| `/var/cache/apt/archives` | _(optional)_ APT package cache — persist to speed up dep installs after `docker rm` |

```
--volume /your/host/steamcmd:/opt/steamcmd
--volume /your/host/gamefiles:/serverdata
--volume /your/host/custom:/opt/custom        # optional
--volume /your/host/apt-cache:/var/cache/apt/archives  # optional, speeds up Wine/dep installs
```

## Environment Variables

| Name | Default | Description |
| --- | --- | --- |
| `STEAMCMD_DIR` | `/opt/steamcmd` | SteamCMD install location |
| `SERVER_DIR` | `/serverdata` | Game files location |
| `GAME_ID` | _(required)_ | Steam App ID (numeric only, e.g. `380870`) |
| `GAME_BRANCH` | `""` | Steam beta branch name (e.g. `unstable`, `experimental`). Leave blank for the default branch |
| `GAME_LAUNCH_CMD` | _(auto-set for known games)_ | Server executable relative to `SERVER_DIR`. Set manually for unlisted games |
| `GAME_PARAMS` | `""` | Arguments appended to `GAME_LAUNCH_CMD` — use for core server settings set by game profiles |
| `GAME_PARAMS_EXTRA` | `""` | Additional arguments appended after `GAME_PARAMS` — use for performance flags and overrides (e.g. `-useperfthreads -NumberOfWorkerThreadsServer=12`) |
| `VALIDATE` | `""` | Set to `true` to validate game files on every start |
| `USERNAME` | `""` | Steam username — leave blank for anonymous login |
| `PASSWRD` | `""` | Steam password — leave blank for anonymous login |
| `ADMIN_PWD` | `""` | Admin password — pass to the game via `GAME_PARAMS` if needed |
| `PUID` | `1000` | Host user ID that owns the mounted volumes |
| `PGID` | `1000` | Host group ID that owns the mounted volumes |

## Hooks

On startup, `start.sh` runs two hook scripts in order (both as `root`):

1. **Game profile hook** — `/opt/custom/<GAME_ID>.sh`  
   Downloaded automatically from this repository when `GAME_ID` is set and no local file exists. Installs game-specific packages, sets `GAME_LAUNCH_CMD`, and exports any required environment variables (e.g. `PATH`, `WINEARCH`). Place a file with the same name in `/opt/custom/` to override.

2. **User hook** — `/opt/custom/user.sh` (falls back to `/opt/scripts/user.sh`)  
   Your custom logic — runs after the game profile so it can extend or override it. Use `export` to pass variables to the server process. A non-zero exit is logged but does not stop the container.

Both hooks are **sourced** (`. hook.sh`), so `export` statements in them propagate to the server process.

### Supported games (auto-configured via `GAME_ID`)

Set only `GAME_ID` — no `GAME_LAUNCH_CMD` needed for these:

| Game | `GAME_ID` | Ports |
|------|-----------|-------|
| Project Zomboid | `380870` | 16261-16262/udp, 27015/tcp |
| Palworld | `2394010` | 8211/udp, 27015/udp |
| Rust | `258550` | 28015/udp, 28016/tcp |
| Satisfactory | `1690800` | 7777/udp, 15000/udp, 15777/udp |
| Arma 3 ¹ | `233780` | 2302-2305/udp |
| Mordhau | `629800` | 7777/udp, 27015/udp |
| Killing Floor 2 | `232130` | 7777/udp, 27015/udp |
| Core Keeper | `1621690` | 27015/udp |
| Euro Truck Simulator 2 | `1948160` | 27015/udp |
| American Truck Simulator | `2239530` | 27015/udp |
| Necesse | `1169370` | 14159/udp |
| DayZ ¹ | `1042420` | 2302/udp, 27016/udp |
| V Rising ² | `1604030` | 9876/udp, 9877/udp |
| ARK: Survival Ascended ² | `2430930` | 7777/udp, 27015/udp |
| Astroneer ² | `728470` | 8777/udp |
| Conan Exiles ² | `443030` | 7777/udp, 27015/udp |
| Sons of The Forest ² | `1326470` | 8766/udp, 27016/udp |
| The Forest ² | `556450` | 8766/udp, 27015/udp |

> ¹ Requires a Steam account that owns the game — set `USERNAME` + `PASSWRD`.  
> ² Windows-only binary running under Wine. Also requires `+@sSteamCmdForcePlatformType windows` in the SteamCMD call — see [scripts/games/README.md](scripts/games/README.md).

---

## Run Examples

### Project Zomboid (auto-configured)
```bash
docker run --name pz-server -d \
  -p 16261-16262:16261-16262/udp -p 27015:27015 \
  --env 'GAME_ID=380870' \
  --env 'ADMIN_PWD=changeme' \
  --env 'PUID=1000' --env 'PGID=1000' \
  --volume /your/host/steamcmd:/opt/steamcmd \
  --volume /your/host/pz-server:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```
> `ADMIN_PWD` is injected as `-adminpassword` automatically. If unset, a random password is generated and printed to the logs.

### Palworld (auto-configured)
```bash
docker run --name palworld-server -d \
  -p 8211:8211/udp -p 27015:27015/udp \
  --env 'GAME_ID=2394010' \
  --env 'GAME_PARAMS=port=8211 queryport=27015 EpicApp=PalServer' \
  --env 'PUID=1000' --env 'PGID=1000' \
  --volume /your/host/steamcmd:/opt/steamcmd \
  --volume /your/host/palworld:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```

### Rust (auto-configured)
```bash
docker run --name rust-server -d \
  -p 28015:28015/udp -p 28016:28016/tcp \
  --env 'GAME_ID=258550' \
  --env 'GAME_PARAMS=-batchmode -nographics +server.port 28015 +server.hostname "My Rust Server" +rcon.port 28016 +rcon.password changeme' \
  --env 'PUID=1000' --env 'PGID=1000' \
  --volume /your/host/steamcmd:/opt/steamcmd \
  --volume /your/host/rust:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```

### Valheim (unlisted — set GAME_LAUNCH_CMD manually)
```bash
docker run --name valheim-server -d \
  -p 2456-2458:2456-2458/udp \
  --env 'GAME_ID=896660' \
  --env 'GAME_LAUNCH_CMD=./valheim_server.x86_64' \
  --env 'GAME_PARAMS=-name MyServer -port 2456 -world Dedicated -password secret -nographics -batchmode' \
  --env 'PUID=1000' --env 'PGID=1000' \
  --volume /your/host/steamcmd:/opt/steamcmd \
  --volume /your/host/valheim:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```

### Satisfactory (auto-configured)
```bash
docker run --name satisfactory-server -d \
  -p 7777:7777/udp -p 15000:15000/udp -p 15777:15777/udp \
  --env 'GAME_ID=1690800' \
  --env 'GAME_PARAMS=-multihome=0.0.0.0 -ServerQueryPort=15777 -BeaconPort=15000 -Port=7777 -log -unattended' \
  --env 'PUID=1000' --env 'PGID=1000' \
  --volume /your/host/steamcmd:/opt/steamcmd \
  --volume /your/host/satisfactory:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```

### CS2 / CS:GO (unlisted — set GAME_LAUNCH_CMD manually)
```bash
docker run --name csgo-server -d \
  -p 27015:27015/udp -p 27015:27015/tcp \
  --env 'GAME_ID=730' \
  --env 'GAME_LAUNCH_CMD=./game/bin/linuxsteamrt64/cs2' \
  --env 'GAME_PARAMS=-dedicated -console +map de_dust2' \
  --env 'PUID=1000' --env 'PGID=1000' \
  --volume /your/host/steamcmd:/opt/steamcmd \
  --volume /your/host/cs2:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```

---

## User Hook example

Drop a `user.sh` in `/opt/custom/` to run custom logic on top of the game profile:

```bash
#!/bin/bash
# /opt/custom/user.sh

# Example: write a server config before launch
cat > "${SERVER_DIR}/serverconfig.xml" <<EOF
<ServerSettings>
  <property name="ServerName" value="My Server" />
</ServerSettings>
EOF
```

The user hook runs after the game profile, as `root`, and is also **sourced** — so `export` works.

## Build

```bash
docker build -t steamcmd:universal .
```
