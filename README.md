# ps1-memcard-sync

A tiny Docker container that keeps PlayStation 1 memory card saves in sync between **MiSTer PSX** and **handheld/libretro cores**:

- MiSTer writes `<game>.sav` (128 KB raw card)
- Libretro/DuckStation/Beetle write `<game>.srm` or `<game>.mcr`

Supported formats
- .sav (MiSTer PSX core)
- .srm (libretro Beetle-PSX, DuckStation)
- .mcr (DuckStation, ePSXe)

This container:
- Mirrors `.sav` → `.srm`/`.mcr` for handhelds
- Mirrors `.srm`/`.mcr` → `.sav` for MiSTer (with a byte-swap so MiSTer recognizes it)
- Preserves timestamps to prevent loops
- Ignores hidden/temp/Syncthing artifacts

It’s best to start a new game/save from MiSTer first, because:
- MiSTer sets the canonical filename — the save is tied to the exact ROM name MiSTer loads. If the file doesn’t exist, MiSTer won’t auto-detect it, even if the data inside is valid.
- Ensures the correct format/endianness — MiSTer’s PSX and N64 cores expect memory cards and SRAM in a specific byte order. If you import a handheld save cold, MiSTer may not recognize it.
- Safe overwrite behavior — once MiSTer has created the base file (.sav, .sra, etc.), sync scripts can safely overwrite it with handheld updates without breaking detection.

## Quick run

```sh
docker run -d \
  --name ps1-memcard-sync \
  --restart unless-stopped \
  -e PUID=1026 -e PGID=100 \
  -v /volume1/MiSTer/saves/PSX:/watch \
  ghcr.io/<youruser>/ps1-memcard-sync:latest
