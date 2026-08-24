# Release Process

This document describes how to cut a new release of CaffeinateBar.
The whole pipeline is automated with GitHub Actions — a human only
bumps the changelog and pushes a tag.

## Versioning

Releases follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

- **MAJOR** — breaking changes (e.g. minimum macOS version bump)
- **MINOR** — new features, backward compatible (e.g. new language, new preset)
- **PATCH** — bug fixes and translations fixes

The version string injected into the app bundle comes from the git tag
(the `v` prefix is stripped), so the tag is the single source of truth.

## Prerequisites

- Push access to `main` on `delineas/caffeinate-bar`
- `gh` CLI authenticated (optional, only to watch the run)

## Cutting a release

### 1. Prepare the changelog

Move everything under `## [Unreleased]` in `CHANGELOG.md` to a new
`## [X.Y.Z] - YYYY-MM-DD` section, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/):

```sh
$EDITOR CHANGELOG.md
git add CHANGELOG.md
git commit -m "Prepare v1.2.3 changelog"
git push origin main
```

### 2. Tag and push

```sh
git tag -a v1.2.3 -m "CaffeinateBar 1.2.3"
git push origin v1.2.3
```

That's it. The `Release` workflow (`.github/workflows/release.yml`)
takes over on every `v*` tag.

### 3. What the workflow does

| Step | Detail |
|---|---|
| Build | `Scripts/build.sh --universal --version "${tag#v}"` — compiles `x86_64` + `arm64`, `lipo`-merges them, ad-hoc signs, validates `Info.plist` and runs the self-test |
| Package | `ditto -c -k --keepParent` → `CaffeinateBar-v1.2.3.zip` + `SHA256SUMS.txt` |
| Publish | `gh release create` with both assets, `--generate-notes --latest` |

Release notes are generated automatically from PR titles/commits since
the previous tag.

## Verifying the release

```sh
gh run watch                       # follow the workflow run
gh release view v1.2.3             # assets must include the zip + SHA256SUMS.txt
```

Sanity-check the artifact locally:

```sh
unzip -q CaffeinateBar-v1.2.3.zip
lipo -info CaffeinateBar.app/Contents/MacOS/CaffeinateBar
# -> Architectures in the fat file: ... are: x86_64 arm64
codesign -dv CaffeinateBar.app 2>&1 | head -1
open CaffeinateBar.app
```

## Troubleshooting

**The workflow failed.** Fix the issue, then either re-run the failed run
(`gh run rerun <id>`) or, if the tag itself is wrong, delete release and
tag and redo step 2:

```sh
gh release delete v1.2.3 --yes
git push origin :refs/tags/v1.2.3
git tag -d v1.2.3
```

**Wrong version inside the app.** The version is read from the tag at
build time. If you moved a tag, delete the release and re-tag (a moved
tag does not re-trigger a completed release).

## Testing a release build locally

You can reproduce the exact release artifact without tagging:

```sh
Scripts/build.sh --universal --version 1.2.3
```

The build fails loudly if the self-test or bundle validation doesn't
pass, so a green local build is a good predictor of a green release.
