# Validation: 2026-10-08

Superseedr Private 1.0.15 is published on `main` with public bottles for Apple
Silicon macOS and x86_64 Linux. No Homebrew account or stored token secrets are
required for installation or the configured release-update workflow.

## Published evidence

- [Formula PR #1](https://github.com/Jagalite/homebrew-tap/pull/1) was published
  through Homebrew's `pr-pull` workflow, which applied the changes and closed
  the PR. The tested PR head was `f7ab4885a212a1802af7b87dfb585fc5c71a3a75`;
  the resulting bottle commit on `main` is `7dfa313`.
- [Bottle CI](https://github.com/Jagalite/homebrew-tap/actions/runs/37812896972)
  passed on macOS 15 ARM64 and x86_64 Linux in Homebrew's container. Both jobs
  built the formula, produced a bottle, reinstalled it, and ran its tests.
  The explicit skipped/failed-formula gate passed on both platforms.
- [Publishing](https://github.com/Jagalite/homebrew-tap/actions/runs/37814534097)
  passed, uploaded both bottles, generated build provenance, and pushed their
  metadata to the tap.
- [Release checks on main](https://github.com/Jagalite/homebrew-tap/actions/runs/37814909598)
  passed with only the built-in `GITHUB_TOKEN`, correctly reporting the latest
  published Superseedr release, 1.0.15, as current. Actions PR creation is enabled
  while default token permissions remain read-only; job permissions are explicit.

Both archives in the [public release](https://github.com/Jagalite/homebrew-tap/releases/tag/superseedr-private-1.0.15)
were downloaded without authentication using system curl with TLS verification.
Their SHA-256 values matched the CI metadata and published formula:

| Bottle | SHA-256 |
| --- | --- |
| `arm64_sequoia` | `b03b2aff382e01f2aa314bab65569282d7e61aa8ddbce58f56dc684c1e60c5e5` |
| `x86_64_linux` | `e425905f47328e5cc117f638b5063c2ba20ee06d56489654d0e29607031fa7aa` |

The CI archives also contained the exact reviewed formula recipe and only the
renamed executable, `bin/superseedr-private`, without `bin/superseedr`.

## Local installation verification

Host: ARM64 macOS 26.5.2, Homebrew 7.0.4, Homebrew Rust 1.99.0.
Source: the published `Jagalite/superseedr` `v1.0.15` archive, SHA-256
`ca658aefa9d39656cffc8af2a0005bf27f9d61bc8d97afdb059dbd970cc89bfa`.
The existing modified Superseedr checkout was not used as build input.

Source installation succeeded with `--locked --no-default-features --bin
superseedr`, followed by renaming the executable. Formula style, strict audit,
CLI tests, and linkage checks passed. An initial local Tahoe bottle was also
created, uninstalled/reinstalled, and tested before publication.

After publication, `brew reinstall --force-bottle jagalite/tap/superseedr-private`
installed the public `arm64_sequoia` bottle. `brew test` and `brew linkage --test`
passed again. The receipt confirms `poured_from_bottle: true`, `arch: arm64`, and
`built_on.os_version: macOS 15.7`, distinguishing it from the earlier local build.
The installed command prints `superseedr 1.0.15`: upstream's displayed product
name remains unchanged, while the executable is named `superseedr-private`.

Build logs, CI archives and install logs are under
`/Volumes/seed2/homebrew-tap-validation/` on the validation host, outside the tap.
The original Superseedr checkout retains its 16 pre-existing modified files;
no changes to that repository were published to its default branch.

## Limits and resolved setup issues

The original Intel macOS job returned success while skipping Superseedr because
Homebrew Rust had no compatible bottle. Current Homebrew metadata confirmed that
missing dependency. Intel macOS was removed from the advertised matrix, and CI
now explicitly rejects skipped/failed formula builds. Intel source builds are
not verified; this is not a claim that the application cannot run there.

The release-check test validates release discovery and the no-change path. A
future version-bump PR, human CI approval, and subsequent upgrade have not yet
been exercised. CLI/package tests do not establish live torrent-transfer
behavior or network privacy properties.

Early local retries resolved an audit against a still-building keg, interference
between concurrent Homebrew Bundler setup commands, and local-archive install
requirements for developer mode and formula-specific trust. The auxiliary
Python downloader lacked local CA certificates; system curl verified the public
downloads normally, without disabling TLS checks. Homebrew marked the local
host Tier 2 due to its Command Line Tools version. Rust/actionlint installation
also upgraded dependencies and triggered Homebrew's automatic old-version
cleanup; later install commands disabled cleanup. No project source files or
pre-existing Superseedr edits were removed or rewritten.
