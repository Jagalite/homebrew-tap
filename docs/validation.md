# Validation: 2026-10-08

## Verified locally

Host: ARM64 macOS 26.5.2, Homebrew 7.0.4, Homebrew Rust 1.99.0.
Source: the published `Jagalite/superseedr` `v1.0.15` archive, SHA-256
`ca658aefa9d39656cffc8af2a0005bf27f9d61bc8d97afdb059dbd970cc89bfa`.
The existing, modified Superseedr checkout was not used as build input.

- `actionlint` passed for all tap workflows and the new upstream notifier.
- `brew style` and `brew audit --strict` passed for `superseedr-private`.
- `brew livecheck --json` identified released version `1.0.15` as current;
  `brew bump --formulae --tap=jagalite/tap` also reported it up to date without
  making an update PR.
- `brew install --build-bottle jagalite/tap/superseedr-private` succeeded. The
  Cargo build log records `--locked --no-default-features --bin superseedr`.
- `brew test` passed on the source installation: version output, CLI help, the
  renamed executable, and absence of an unrenamed executable inside the keg.
- `brew linkage --test` passed.
- `brew bottle --json` produced a relocatable `arm64_tahoe` bottle, SHA-256
  `f4b9462fe389ab748ac436ff1afb34da4a122c540f3cc08cf1e0387846e1c8ab`.
- After uninstalling the source installation, installing that bottle succeeded.
  `brew test` and `brew linkage --test` passed again. The installed receipt says
  `poured_from_bottle: true`, `built_as_bottle: true`, and `arch: arm64`.
- `/opt/homebrew/bin/superseedr-private --version` returns `superseedr 1.0.15`.
  The upstream CLI's displayed product name remains `superseedr`; the installed
  executable is named `superseedr-private` and is a native ARM64 Mach-O binary.

The local bottle and build/installation logs are under
`/Volumes/seed2/homebrew-tap-validation/` on the validation host. They are not
committed or published. In particular, this locally built Tahoe bottle is not
one of the planned macOS 15 CI bottles, and no unhosted bottle block is inserted
into the formula.

## Problems encountered and resolved

An audit run while the source install was still building reported an empty keg;
it passed after installation finished. Parallel Homebrew developer commands
interfered with shared Bundler gem setup during the first bottling attempt;
serial retry succeeded. Subsequent Homebrew checks ran serially.

Direct local archive installation initially failed because Homebrew 7 requires
`HOMEBREW_DEVELOPER=1` for that operation. After uninstalling, the formula also
needed its specific trust entry restored with `brew trust --formula`. Both were
applied for the local bottle test; whole-tap trust was not granted.

The build emitted upstream Rust deprecation warnings but succeeded. Homebrew
reported this host as Tier 2 due to its Command Line Tools version. Validation
installed Homebrew Rust and actionlint plus dependencies; Homebrew also upgraded
some existing dependencies and ran its automatic old-version cleanup during
that initial tool install. Subsequent install commands disabled automatic
cleanup. No source files or existing Superseedr edits were removed or rewritten.

## Not yet verified or activated

- No tap commits have been pushed, GitHub Actions jobs run, bottle assets uploaded,
  or formula/bottle PRs published. Remote `brew install` is not yet available.
- Intel macOS and Linux builds, the complete hosted CI matrix, release PR creation,
  the credentialed dispatch, and public bottle downloads remain unverified.
- Both `TAP_UPDATE_TOKEN` in the tap and `HOMEBREW_TAP_TOKEN` in Superseedr are
  absent. Credentials must be configured to activate the automation.
- The notifier is an additional uncommitted file in the existing Superseedr
  checkout. All 16 previously modified files there were left untouched.
- This smoke test does not establish live torrent-transfer behavior or network
  privacy properties. The no-default-features build is established by the build
  invocation and source feature definitions.

Follow the first-publication steps in [the maintainer guide](maintaining.md).
