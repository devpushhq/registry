# /dev/push registry

This repository contains:
- The published registry catalog (`manifest/`), served as static JSON files.
- Docker build contexts for official runner images (`runners/`).

The minimal "API" is just fetching the latest compatible catalog file, for example:
- `manifest/v1/manifest.json` (latest v1 catalog)

Instances can ship with a bundled catalog and optionally sync from this repo.

## Image namespace

Runner images are published to GitHub Container Registry under the repo owner
namespace, e.g. `ghcr.io/devpushhq/runner-go-1.25:1.0.0`.

## Tag strategy

- Default: immutable release tags, e.g. `:1.0.0` (matches `meta.registry_version`).
- Optional later: moving convenience tags (e.g. `:8.3`, `:1.25`) if you decide you
  want automatic upgrades when pulling; you can always pin a specific image
  digest via `@sha256:...` in DevPush overrides.

## Publishing

This repo does not need a custom API service; it can be served via raw GitHub
URLs or GitHub Pages. Runner images are built/pushed by GitHub Actions when you
push a tag like `1.0.0`.
