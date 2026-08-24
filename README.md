# CaffeinateBar

[![CI](https://github.com/delineas/caffeinate-bar/actions/workflows/ci.yml/badge.svg)](https://github.com/delineas/caffeinate-bar/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/delineas/caffeinate-bar)](https://github.com/delineas/caffeinate-bar/releases)
[![macOS](https://img.shields.io/badge/macOS-11%2B-black)](https://github.com/delineas/caffeinate-bar)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A macOS menu bar app that keeps your Mac awake. One Swift file, zero dependencies:
it wraps the `caffeinate` tool that already ships with the system.

Also available in [Español](README.es.md).

## Features

- Coffee cup in the menu bar: full = active, empty = idle.
- Durations: indefinite, 15 min, 30 min, 1 h, 2 h, 5 h and 8 h (workday).
- Live countdown in the menu and tooltip; the icon turns orange in the last 10 minutes.
- "Keep display awake" option (`-d` flag), remembered between sessions.
- Localized in English and Spanish — add more languages with two files (see [Localization](#localization)).
- No Dock icon (`LSUIElement`).
- If the app quits or crashes, `caffeinate` dies with it (`-w <pid>`): no orphan processes.
- Universal binary (Apple Silicon + Intel), ad-hoc signed.

## Install

Download the latest build from [Releases](https://github.com/delineas/caffeinate-bar/releases),
unzip, and drag `CaffeinateBar.app` to `/Applications`. Launch it and look for the cup
in your menu bar. To start it at login, add it in
System Settings → General → Login Items.

Or build it yourself:

```sh
Scripts/build.sh
open build/CaffeinateBar.app
```

Requires Xcode Command Line Tools (`xcode-select --install`).

## Usage

| Menu item | What it does |
|---|---|
| Start / Stop | Toggles the keep-awake session |
| Duration | Picks the timeout; the countdown shows in the menu and tooltip |
| Keep display awake | Also prevents the screen from sleeping |
| Quit | Stops `caffeinate` and exits |

## Development

```
Sources/CaffeinateBar/   App source (single file)
Resources/               Localizable.strings + app icon
Scripts/build.sh         Build, bundle, sign and self-test
Scripts/make_icon.sh     Regenerate the app icon
```

Useful commands:

```sh
Scripts/build.sh --universal          # arm64 + x86_64 binary
Scripts/build.sh --version 1.2.3      # inject a version string
Scripts/make_icon.sh                  # regenerate Resources/AppIcon.icns
```

The build runs a self-test (`--selftest` flag on the binary) that verifies the clock
format, the warning threshold, bundle localization and the real `caffeinate`
lifecycle. It exits non-zero on failure, so it works as a CI gate.

### Localization

The app reads `Localizable.strings` from the bundle. To add a language:

1. Create `Resources/<lang>.lproj/Localizable.strings` (copy the English file as a start).
2. Add `<string><lang></string>` to `CFBundleLocalizations` in `Scripts/build.sh`.
3. Rebuild. macOS picks the language automatically from system preferences.

### Releases

Releases are fully automated:

1. Bump and tag: `git tag v1.2.3 && git push origin v1.2.3`
2. GitHub Actions builds a universal binary, packages it with `ditto`, and
   publishes a GitHub Release with the zip and its SHA256 checksums.

## Contributing

PRs are welcome. Keep the single-file, zero-dependency spirit: no frameworks,
no external packages. Run `Scripts/build.sh` before pushing — CI must stay green.
See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © Daniel Primo
