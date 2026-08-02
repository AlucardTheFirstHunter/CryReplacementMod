# Changelog

## [1.1.0] - 2026-08-02

### Fixed

- Cries were silent on Steam Deck / Linux (worked on macOS): the pack
  files live under `mods/<id>/assets/...`, and `love.audio.newSource` was
  handed that virtual love.filesystem path, which only resolves when the
  mods tree sits on the read path (save dir / dev checkout).  On a
  packaged or portable install it does not, so every pack source failed,
  the engine's per-species cry cache was poisoned, and all cries went
  silent.
- Pack files are now staged into the LOVE save directory under
  `mod-derived/CryReplacementMod/<pack>/` (via `love.filesystem.write`,
  the same home the engine uses for its own decoded pika_cries WAVs) and
  the cries table points at those paths.  The save directory is always on
  love.filesystem's read path, so cries resolve identically on macOS,
  Windows, Linux and Steam Deck.
- Pack bytes are read with `mod:read`, the same channel the loader used
  to read `main.lua`, so staging works wherever the mod itself loads.
- Removed the `io.open`/`getInfo` existence probe that could report a
  file as present (relative to the process working directory) while
  `love.audio.newSource` still failed to resolve it.
