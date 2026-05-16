# DayZ Server — Operations

A DayZ server runs as an ad-hoc Docker container on the OCI Ampere instance provisioned by this repo. The container itself is not managed by Terraform; only the network/firewall and the host VM are. This document captures the manual setup and ongoing operations.

## Location

- Host: `ubuntu@137.131.228.41` (OCI Ampere A1.Flex, aarch64, Ubuntu 22.04)
- Container: `dayzpiserver` (image `artemisian/steamcmd-dayz:latest`, x86_64 binaries translated by FEX-Emu via binfmt_misc)
- Persistent volume: `dayz-server-data` mounted at `/home/` inside the container. All state (serverfiles, mods, configs, profiles) lives here.
- Config paths inside container:
  - `/home/config.ini` — script config (Steam login, mod list, launch params)
  - `/home/workshop.cfg` — one Steam Workshop mod ID per line
  - `/home/serverfiles/serverDZ.cfg` — DayZ server config (hostname, password, mission template)
  - `/home/dayzserver.sh` — patched start/stop/update script (HaywarGG's, with `-mod=` fix — see Gotchas)
  - `/home/serverprofile/` — runtime profiles, RPT logs, mod-created configs

## Everyday commands

From your workstation:
```
ssh ubuntu@137.131.228.41
docker exec -it dayzpiserver bash     # drop into container as steam user
./dayzserver.sh start|stop|restart|monitor
```

Tail the active log from outside the container:
```
ssh ubuntu@137.131.228.41 'docker exec dayzpiserver bash -lc "tail -f \$(ls -t /home/serverprofile/*.RPT | head -1)"'
```

Restart the container itself (e.g. after host reboot):
```
docker start dayzpiserver
```

## Container creation

The container must be recreated with FEX binaries bind-mounted from the host — the image doesn't ship FEX, and the host's binfmt_misc handler expects `/usr/bin/FEX` + `FEXServer` to be visible inside the container's mount namespace. Exact command:

```bash
docker rm -f dayzpiserver 2>/dev/null
docker run -i -t -d \
  --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined \
  -v /usr/bin/FEX:/usr/bin/FEX:ro \
  -v /usr/bin/FEXInterpreter:/usr/bin/FEXInterpreter:ro \
  -v /usr/bin/FEXServer:/usr/bin/FEXServer:ro \
  -v /usr/bin/FEXBash:/usr/bin/FEXBash:ro \
  -v /usr/bin/FEXConfig:/usr/bin/FEXConfig:ro \
  -v /usr/bin/FEXGetConfig:/usr/bin/FEXGetConfig:ro \
  -v /usr/bin/FEXRootFSFetcher:/usr/bin/FEXRootFSFetcher:ro \
  -v /usr/share/fex-emu:/usr/share/fex-emu:ro \
  -v /home/ubuntu/.local/share/fex-emu/RootFS:/home/steam/.local/share/fex-emu/RootFS:ro \
  -p 2302:2302/udp -p 2303:2303/udp -p 2304:2304/udp -p 2305:2305/udp \
  -p 8766:8766/udp -p 27016:27016/udp \
  -v dayz-server-data:/home/ \
  --name dayzpiserver artemisian/steamcmd-dayz:latest

# One-time fixup (FEX paths inside the volume + server pipe dirs)
docker exec -u root dayzpiserver bash -lc '
  CFG='"'"'{"Config":{"RootFS":"/home/steam/.local/share/fex-emu/RootFS/Ubuntu_22_04"},"ThunksDB":{}}'"'"'
  for d in /home/.config/fex-emu /home/steam/.config/fex-emu /home/.fex-emu /home/steam/.fex-emu /etc/fex-emu; do
    mkdir -p "$d" && echo "$CFG" > "$d/Config.json"
  done
  mkdir -p /home/steam/.fex-emu/Server /home/.fex-emu/Server
  chown -R steam:steam /home/steam/.config /home/steam/.fex-emu /home/.config /home/.fex-emu
'
```

FEX rootfs must be staged on the host first: `FEXRootFSFetcher -y` as `ubuntu`. That's a one-time host setup.

## Network — two layers

OCI security and host firewall both need the DayZ ports open (UDP). Current open ports:

- `2302-2305/udp` — DayZ game + query + reserved
- `8766/udp` — Steam P2P
- `27016/udp` — Steam master query

Layer 1, VCN security list: managed in `modules/network/main.tf` of this repo.
Layer 2, host iptables:
```
sudo iptables -I INPUT 4 -p udp --dport 2302:2305 -m state --state NEW -j ACCEPT
sudo iptables -I INPUT 4 -p udp --dport 8766 -m state --state NEW -j ACCEPT
sudo iptables -I INPUT 4 -p udp --dport 27016 -m state --state NEW -j ACCEPT
sudo netfilter-persistent save
```

## Switching maps

Three missions are pre-installed: `dayzOffline.chernarusplus`, `dayzOffline.enoch` (Livonia), `dayzOffline.sakhal`. Edit the `template=` line in `/home/serverfiles/serverDZ.cfg`, then restart.

For community map mods, you also install the map as a workshop mod and change `template=` to whatever the map's docs specify.

## Adding mods

Use the `add-dayz-mod` skill for the exact procedure. Short version:

1. Add each Steam Workshop ID to `/home/workshop.cfg` (one per line).
2. `./dayzserver.sh restart` — the script downloads mods and symlinks them as `@<lowercase-name>` under `/home/serverfiles/`. Mod names can contain spaces (e.g. `@military backpack`).
3. Read back the actual folder names with `readlink` (don't parse `ls -l` — spaces in names break it).
4. Edit `/home/config.ini` to set `workshop="@cf;@vanillaplusplusmap;..."` (semicolon-separated, lowercase).
5. `./dayzserver.sh restart` again to load with `-mod=`.

Server-side-only mods (admin tools etc.) go in `servermods=` instead of `workshop=`.

BattlEye keys are auto-copied from each `@mod/Keys/*.bikey` into `/home/serverfiles/keys/` on every restart.

## Spawn selection (zSpawnSelection)

Spawn points are in `/home/serverprofile/zSpawnSelect/SpawnLocations.json`. Coordinates must match the active map — default ships with Chernarus coordinates. When switching maps, rewrite the JSON with map-valid coordinates (Livonia towns currently populated from the vanilla `cfgplayerspawnpoints.xml`).

## Gotchas (things we hit and fixed)

1. **FEX binaries aren't in the image.** Container depends on host's `/usr/bin/FEX*` being bind-mounted in. Without this, FEXServer can't spawn and steamcmd fails with `Couldn't execute: FEXServer`.

2. **Steam user's `$HOME` disagrees with pw_dir.** `$HOME=/home` but `/etc/passwd` says `/home/steam`. FEX uses `getpwuid()->pw_dir`, so its config must be at `/home/steam/.config/fex-emu/`. We blanket-write Config.json to five locations to cover all lookup paths.

3. **`dayzserver.sh` didn't pass `-mod=`.** The upstream script only appends `-servermod=` on the launch line — the `workshop=` value from config.ini was silently ignored. Patched on line 163 to also pass `-mod="$workshop"`. Backup at `/home/dayzserver.sh.bak`.

4. **Mod folder names are lowercased and can contain spaces.** The script derives `@<name>` by reading each mod's `meta.cpp` `name=` field and lowercasing. So "Military Backpack" → `@military backpack`. Any config or parsing that splits on whitespace will break. Use `readlink` on `@*` symlinks to get exact names.

5. **Performance.** FEX on Ampere is faster than qemu but it's still emulation. Expect noticeably lower TPS than native x86, especially with many mods + players. Keep the mod list lean.

## Logs and debugging

- RPT logs: `/home/serverprofile/*.RPT` — newest file is current run. Grep for `ERROR`, `CANNOT LOAD`, `MISSING ADDON`, `Init sequence finished`, `Player connect enabled`.
- Server crashes: `.mdmp` files in same directory.
- Steam/auth issues: `/home/Steam/logs/stderr.txt`.

## Backups

The script auto-backs up the mission folder and serverprofile into `/home/backup/` on each start; retention is 2 days. The Docker named volume `dayz-server-data` holds everything; back it up from the host with `docker run --rm -v dayz-server-data:/data -v $(pwd):/backup alpine tar czf /backup/dayz-$(date +%F).tgz -C /data .` before risky operations.
