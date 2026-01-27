This folder contains the published catalog for schema major v1.

Files:
- `manifest.json`: the latest catalog (single source of truth for v1).

Format (high level):
- `meta`: minimal metadata about the catalog.
  - `version`: catalog release version (should match the git tag used to publish).
  - `source`: `registry` for published catalogs.
- `runners[]`: list of runnable images.
  - `slug`, `name`, `category`, `image` (full image ref with tag).
- `presets[]`: list of detection/commands presets.
  - `slug`, `name`, `category`, `config` (includes runner + commands + detection).

Notes:
- Schema changes should be backward compatible within `v1`. Breaking changes
  should be published under `catalog/v2/`.
