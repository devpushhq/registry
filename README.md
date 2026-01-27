# /dev/push registry

This repository contains:
- The published registry catalog (`catalog/`), served as static JSON files.
- Docker build contexts for official runner images (`runners/`).

The minimal "API" is just fetching the latest compatible catalog file, for example:
- `catalog/v1/catalog.json` (latest v1 catalog)

Instances can ship with a bundled catalog and optionally sync from this repo.

## Image namespace

Runner images are published to GitHub Container Registry under the repo owner
namespace, e.g. `ghcr.io/devpushhq/runner-go-1.25:1.0.0`.

## Tag strategy

- Runner images use per-runner tags in `catalog/v1/catalog.json` and may differ from the catalog tag.
- If a runner Dockerfile changes, its image tag must be bumped in the catalog (workflow enforces this).
- `:latest` is published for convenience and points at the newest release.

## Publishing

This repo does not need a custom API service; it can be served via raw GitHub
URLs or GitHub Pages. Runner images are built/pushed by GitHub Actions when you
push a tag like `1.0.0`.
