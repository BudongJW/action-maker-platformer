# assets_private (never committed)

Files in this folder are excluded by `.gitignore`; only this README is tracked.

Put **assets that must not be redistributed** here (GGG RTP/DLC and built-in assets, Japanese free BGM/SFX, paid packs, etc.). They are included in game builds but never pushed to the public repository.

## Rules

1. Every time you add an asset, record where it came from, its path, a summary of its terms and the date you checked them in [`SOURCES.md`](../SOURCES.md), and add its credit to [`CREDITS.md`](../CREDITS.md).
2. Organize subfolders the same way as `assets/`.

```
assets_private/
├── audio/
│   ├── bgm/
│   └── se/
├── graphics/
│   ├── tilesets/
│   ├── characters/
│   └── portraits/
└── ggg_dlc/<pack name>/      # Official GGG DLC (check the pack's readme conditions)
```

3. Before committing, run `git status` to confirm nothing in this folder is tracked. If something was committed by mistake, undo it before pushing; if it was already pushed, it has to be removed from the history.

## In a fresh clone

Obtain the files listed in `SOURCES.md` and place them at the listed paths to be able to build. Scenes that reference missing files will show missing-resource warnings.
