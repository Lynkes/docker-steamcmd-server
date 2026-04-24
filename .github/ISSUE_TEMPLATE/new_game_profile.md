---
name: New game profile
about: Request or contribute a scripts/games/<GAME_ID>.sh profile for a new game
labels: new-game
---

## Game details

| Field | Value |
|-------|-------|
| Game name | |
| Steam App ID | |
| Steam store page | |
| Linux native? | Yes / No (Wine required) |
| Anonymous login? | Yes / No (requires owning the game) |

## Default ports

| Port | Protocol | Purpose |
|------|----------|---------|
| | | |

## `GAME_LAUNCH_CMD`

<!-- The executable path relative to SERVER_DIR, e.g. `./start-server.sh` -->

```
./
```

## Runtime dependencies

<!-- List any packages that must be installed before the server starts (e.g. openjdk-21-jre-headless, winehq-stable). -->

- 

## Notes / special setup

<!-- Anything unusual: Windows-only binary, Wine prefix config, Xvfb, extra env vars needed, etc. -->

## Have you tested this?

- [ ] Yes — I can share a working `docker run` command
- [ ] No — I'm requesting someone else add support

```bash
# Working run command (if tested):
docker run --name test-server -d \
  --env 'GAME_ID=<ID>' \
  --volume /tmp/steamcmd:/opt/steamcmd \
  --volume /tmp/serverdata:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```
