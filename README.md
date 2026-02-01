# /dev/push registry

This repo is the registry for /dev/push:
- The published catalog (`catalog/`), served as static JSON.
- Docker build contexts for official runner images (`runners/`).

There is no custom API service. Clients fetch the catalog from a static URL,
for example:
- `https://raw.githubusercontent.com/devpushhq/registry/main/catalog/v1/catalog.json` (latest v1 catalog)

Instances can ship with a bundled catalog and optionally sync from this repo.

## Catalog format

The catalog is a JSON file with:
- `meta`: version and source metadata.
- `runners`: list of runner definitions (slug, name, category, image).
- `presets`: list of preset definitions (slug, name, category, config).

The schema is documented in `catalog/v1/README.md`.

## Image namespace and tags

Runner images are published to GitHub Container Registry under the repo owner
namespace, e.g. `ghcr.io/devpushhq/runner-go-1.25:1.0.0`.

Tag strategy:
- Runner images use per-runner tags in `catalog/v1/catalog.json` and may differ
  from the catalog tag.
- If a runner Dockerfile changes, its image tag must be bumped in the catalog
  (workflow enforces this).
- `:latest` is published for convenience and points at the newest release.

## Adding a runner image

1) Create a runner folder:
```
runners/<slug>/
  Dockerfile
```

2) Base image and entrypoint:
- Copy and use the shared entrypoint from `runners/_common/entrypoint.sh`.
- Ensure `/app`, `/data`, and `/cache` exist (the entrypoint expects them).
- Set `WORKDIR /app`.

3) Required runtime behavior:
- The image must start as root and drop to `appuser` via the entrypoint.
- The entrypoint handles UID/GID remapping using `SERVICE_UID` / `SERVICE_GID`.
- The runner must be able to run user commands in `/app` and read/write
  `/data` and `/cache`.

4) Update the catalog:
- Add the runner entry to `catalog/v1/catalog.json` with the image tag.
- If this is a new runner, include it in presets as needed.
- If a runner Dockerfile changes (or `_common/entrypoint.sh` changes), bump the
  image tag for that runner in the catalog. An entrypoint change requires
  bumping *all* runner image tags.

5) Build and publish:
- Push a git tag (e.g. `1.0.0`) to trigger the GitHub Actions workflow.

## Local testing

Build locally:
```
docker build -t local/runner-<slug>:dev runners/<slug>
```

Run:
```
docker run --rm -it \
  -e SERVICE_UID=$(id -u) \
  -e SERVICE_GID=$(id -g) \
  -v "$PWD":/app \
  local/runner-<slug>:dev
```

## Publishing

This repo can be served via raw GitHub URLs or GitHub Pages. Runner images are
built/pushed by GitHub Actions when you push a tag like `1.0.0`.

## Build rules (what triggers builds)

The workflow only runs on tag pushes that match `*.*.*` (e.g. `1.0.1`).
It computes a build plan from git diff vs the previous tag:

- If `runners/_common/**` changes, *all* runners are rebuilt.
- If a specific runner folder changes, only that runner is rebuilt.
- If no runner folders changed, runners are **retagged** from the previous
  release (no rebuild).

Catalog enforcement:
- For any runner that is rebuilt, the image tag **must** change in
  `catalog/v1/catalog.json` or the workflow fails.
- If you touched `_common/entrypoint.sh`, you must bump **every** runner image
  tag in the catalog.
