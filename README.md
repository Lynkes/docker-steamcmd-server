# Project Zomboid Dedicated Server in Docker

Runs a Project Zomboid dedicated server via SteamCMD. On first start the bundled server configuration template (`config/cfg/Zomboid/`) is automatically copied into the server data directory.

**Update:** Restart the container to update to the latest game version. Set `VALIDATE=true` to force a full file validation.

## Java Runtime & JVM Optimization

The image ships **GraalVM Community Edition 25.0.2** (64-bit), installed at `/opt/graalvm` via a multi-stage Docker build. The Graal JIT compiler is enabled through JVMCI flags. The game's own bundled JRE is replaced at runtime with a symlink to `/opt/graalvm`.

JVM tuning is controlled by the JSON files next to the launchers:

| File | Launcher | GC | JIT |
| --- | --- | --- | --- |
| `ProjectZomboid64.json` | `ProjectZomboid64` | G1GC | GraalVM community (JVMCI) |
| `ProjectZomboid32.json` | `ProjectZomboid32` | G1GC | default |

### Heap

- **`-Xms256m`** — JVM starts with a minimal 256 MB heap and grows on demand rather than pre-allocating a large block at startup.
- **`-Xmx16g`** — Hard cap at 16 GB; increase if your host has more RAM and a large number of players/mods.

### G1GC Tuning

| Flag | Value | Intent |
| --- | --- | --- |
| `MaxGCPauseMillis` | `50` | Target pause budget — keeps GC pauses short enough that players don't notice lag spikes |
| `G1HeapRegionSize` | `16m` | Larger regions reduce region-management overhead for a heap in the 4–16 GB range |
| `G1NewSizePercent` | `20` | Minimum young-gen size — reduces premature promotions to old gen |
| `G1MaxNewSizePercent` | `40` | Caps young-gen growth so GC pauses stay within the target budget |
| `InitiatingHeapOccupancyPercent` | `25` | Starts concurrent marking earlier (default 45%) to avoid the heap filling up and forcing a Stop-the-World Full GC |
| `G1MixedGCLiveThresholdPercent` | `65` | Includes old-gen regions with up to 65% live data in mixed GCs — cleans old gen more aggressively and reduces Full GC risk |
| `G1RSetUpdatingPauseTimePercent` | `5` | Limits pause time spent updating remembered sets |
| `ParallelRefProcEnabled` | — | Processes reference objects in parallel during GC |
| `PerfDisableSharedMem` | — | Disables JVM perf data shared memory — reduces file I/O in containers |
| `DisableExplicitGC` | — | Prevents `System.gc()` calls from forcing a Full GC |
| `UseStringDeduplication` | — | Deduplicates identical `String` objects in the heap — useful for a game that loads many repeated strings from map/mod data |

### GraalVM JIT (JVMCI)

| Flag | Intent |
| --- | --- |
| `EnableJVMCI` + `UseJVMCICompiler` | Replaces the default C2 JIT with the Graal compiler for higher peak throughput |
| `CompilerConfiguration=community` | Uses the full community Graal tier (most aggressive optimizations) |
| `ReservedCodeCacheSize=1024m` | Gives the JIT compiler 1 GB of code cache so hot paths are never evicted |

## Server Configuration

The default configuration template lives in `config/cfg/Zomboid/` and is copied into the container at `/opt/config/cfg/Zomboid/`. On first startup, if `${SERVER_DIR}/Zomboid` does not exist, it is seeded from this template. Subsequent starts skip the copy and use the existing (potentially modified) data.

Configuration files included:

- `Server/servertest.ini` — main server settings
- `Server/servertest_SandboxVars.lua` — sandbox tuning
- `Server/servertest_spawnpoints.lua` — spawn points
- `Server/servertest_spawnregions.lua` — spawn regions
- `options.ini` — global options

## Environment Variables

| Name | Description | Default |
| --- | --- | --- |
| `STEAMCMD_DIR` | SteamCMD installation directory | `/serverdata/steamcmd` |
| `SERVER_DIR` | Game files directory | `/serverdata/serverfiles` |
| `GAME_ID` | Steam App ID — use `380870 -beta unstable` for B42.17+ | `380870` |
| `ADMIN_PWD` | In-game admin password | `adminDocker` |
| `GAME_PARAMS` | Extra arguments passed to the server launcher | _(empty)_ |
| `VALIDATE` | Set to `true` to validate game files on every start | _(empty)_ |
| `USERNAME` | Steam username (leave blank for anonymous login) | _(empty)_ |
| `PASSWRD` | Steam password (leave blank for anonymous login) | _(empty)_ |
| `PUID` | User ID the server process runs as | `568` |
| `PGID` | Group ID the server process runs as | `568` |
| `UMASK` | File creation mask | `022` |
| `DATA_PERM` | Permissions applied to the data directory | `770` |

## Run Example

```bash
docker run --name ProjectZomboid -d \
    -p 16261-16262:16261-16262/udp \
    -p 27015:27015/tcp \
    --env 'GAME_ID=380870' \
    --env 'ADMIN_PWD=changeme' \
    --env 'PUID=568' \
    --env 'PGID=568' \
    --volume /path/to/steamcmd:/serverdata/steamcmd \
    --volume /path/to/projectzomboid:/serverdata/serverfiles \
    ich777/steamcmd:projectzomboid
```

## TrueNAS / Docker Compose

A ready-to-use `truenas.yaml` is included at the root of the repository. It configures the container for TrueNAS Scale (or any Docker Compose environment) with `network_mode: host`, bind mounts under `/mnt/vdev/apps/`, and the built-in `apps` user (`PUID`/`PGID=568`).

## Volumes

| Container path | Purpose |
| --- | --- |
| `/serverdata/steamcmd` | SteamCMD cache — persist to avoid re-downloading |
| `/serverdata/serverfiles` | Game files + world saves + server config |

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| `16261` | UDP | Game traffic (primary) |
| `16262` | UDP | Game traffic (secondary) |
| `27015` | TCP | Steam query / RCON |

## Startup Sequence

1. Install / update SteamCMD if not present
2. Update (or validate) game files via SteamCMD
3. Set up `LD_LIBRARY_PATH` for native libraries
4. Replace game's bundled `jre64/` with a symlink to `/opt/graalvm`
5. Seed `${SERVER_DIR}/Zomboid` from `/opt/config/cfg/Zomboid/` if missing
6. Clean up old log file (`masterLog.0`)
7. Launch `ProjectZomboid64` inside a `screen` session
8. Launch watchdog — terminates the container when the server process exits
9. Tail `masterLog.0` to stdout

---

Forked from [mattieserver](https://github.com/mattieserver). Originally adapted for Unraid by [ich777](https://github.com/ich777/docker-steamcmd-server).

Support thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/