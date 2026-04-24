## What does this PR do?

<!-- Brief description of the change and why it's needed. -->

## Type of change

- [ ] Bug fix
- [ ] New game profile (`scripts/games/<GAME_ID>.sh`)
- [ ] New feature
- [ ] Documentation update
- [ ] CI / Dockerfile change

## Checklist

- [ ] Hook file is named `<GAME_ID>.sh` (numeric Steam App ID)
- [ ] Hook exports `GAME_LAUNCH_CMD` with a sane default (`${GAME_LAUNCH_CMD:-...}`)
- [ ] Any `apt-get install` is guarded with `dpkg -s <pkg>` to skip on restart
- [ ] Heavy downloads (tarballs, etc.) are guarded by a marker file in `${STEAMCMD_DIR}`
- [ ] Wine games: `export WINEARCH` + `export WINEPREFIX` are set
- [ ] Windows-only games: `+@sSteamCmdForcePlatformType windows` is documented
- [ ] `scripts/games/README.md` updated (if adding a new game profile)
- [ ] Root `README.md` Supported games table updated (if adding a new game profile)
- [ ] Scripts pass `shellcheck` without errors (warnings acceptable)

## Testing

<!-- Describe how you tested the change (e.g. `docker run` command used, game version, host OS). -->

```bash
docker run --name test-server -d \
  --env 'GAME_ID=<ID>' \
  --volume /tmp/steamcmd:/opt/steamcmd \
  --volume /tmp/serverdata:/serverdata \
  ghcr.io/lynkes/steamcmd_docker:latest
```

## Related issues

<!-- Closes #... -->
