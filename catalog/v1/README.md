This folder contains the published catalog for schema major v1.

Files:
- `catalog.json`: the latest catalog (single source of truth for v1).

Format (high level):
- `meta`: minimal metadata about the catalog.
  - `version`: catalog release version.
  - `source`: `registry` for published catalogs.
- `runners[]`: list of runnable images.
  - `slug`, `name`, `category`, `image` (full image ref with tag).
- `presets[]`: list of detection/commands presets.
  - `slug`, `name`, `category`, `config` (includes runner + commands + detection).

Notes:
- Schema changes should be backward compatible within `v1`. Breaking changes
  should be published under `catalog/v2/`.
- Runner image tags are per-runner and can differ from the catalog `meta.version`.
