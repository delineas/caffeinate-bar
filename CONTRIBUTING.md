# Contributing

Thanks for your interest in CaffeinateBar. A few ground rules to keep this
project small, sharp and dependency-free.

## Principles

- **One Swift file, zero dependencies.** No frameworks, no Swift Package Manager
  dependencies, no external binaries beyond the system `caffeinate`.
- **macOS 11+ (Big Sur).** Avoid APIs newer than that.
- **Self-tested.** Anything testable without a GUI belongs in `selfTest()`.

## Getting started

```sh
xcode-select --install      # if you don't have the CLT
Scripts/build.sh            # builds into build/ and runs the self-test
```

## Before you open a PR

1. `Scripts/build.sh` must pass (it runs the self-test).
2. Keep the diff minimal — one logical change per PR.
3. If you add user-facing strings, add them to **both**
   `Resources/en.lproj/Localizable.strings` and `Resources/es.lproj/Localizable.strings`.
4. Update `CHANGELOG.md` under **Unreleased**.
5. Write commit messages in English, imperative mood (`Add`, `Fix`, `Remove`).

## Reporting bugs

Open an issue with: macOS version, Mac architecture (Intel/Apple Silicon),
and the steps to reproduce. Include console output if `caffeinate` is involved.
