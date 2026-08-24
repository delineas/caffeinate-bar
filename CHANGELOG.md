# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-08-24

### Added

- Internationalization: English and Spanish, resolved automatically from system
  preferences (`Localizable.strings` per language in the app bundle).
- Application icon (Big Sur style squircle) generated from a script
  (`Scripts/make_icon.sh`), committed as `AppIcon.icns`.
- GitHub Actions CI: universal build + self-test on every push/PR.
- GitHub Actions release pipeline: tag `v*` → universal build, zip + SHA256,
  automated GitHub Release.
- MIT license, changelog and contribution guidelines.

### Changed

- Project restructured: `Sources/`, `Resources/`, `Scripts/`, build output in `build/`.
- Build script rewritten: native arch by default, `--universal` and `--version`
  flags, ad-hoc codesigning, `plutil` validation and self-test gate.
- Bundle identifier changed from `local.caffeinate-bar` to `com.delineas.caffeinate-bar`.

### Removed

- Prebuilt `.app` no longer lives in the repository root.

## [1.0.0] - 2026-08-24

### Added

- Initial release: menu bar coffee cup wrapping `caffeinate`, duration presets,
  countdown with warning state, "keep display awake" option, orphan-proof
  process handling.
