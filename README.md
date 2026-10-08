# Jagalite Homebrew tap

A shared tap for Jagalite projects. Each package lives in its own `Formula/*.rb`;
CI and release checks discover formulae across the tap.

| Formula | Upstream | Build |
| --- | --- | --- |
| `superseedr-private` | [Superseedr](https://github.com/Jagalite/superseedr) | `--no-default-features`; no DHT, PEX, or WebTorrent |

## Install

Once the tap is published:

```sh
brew install Jagalite/tap/superseedr-private
superseedr-private --version
brew test Jagalite/tap/superseedr-private
```

Or run `brew tap Jagalite/tap`, then install the fully qualified formula above.
No GitHub account, token, or private-repository access is required to install.
“Private” describes the feature selection, not the repository visibility. This
build does not provide anonymity or isolate its configuration from other
Superseedr installations. It installs only `superseedr-private`, leaving any
existing `superseedr` executable alone. Avoid running both against the same data
or configuration simultaneously.

Homebrew uses a matching published bottle when one exists. Otherwise it builds
from the checksummed release source with Homebrew Rust and the Cargo lockfile.
The CI bottle targets are macOS 15 Apple Silicon, macOS 15 Intel, and x86_64 Linux
in Homebrew's official Linux container. Other compatible hosts may build from
source; these three targets are not a claim of testing on every OS version.

To explicitly build from source:

```sh
brew install --build-from-source Jagalite/tap/superseedr-private
```

## Upgrade and remove

```sh
brew update
brew outdated Jagalite/tap/superseedr-private
brew upgrade Jagalite/tap/superseedr-private
superseedr-private --version
```

`brew uninstall Jagalite/tap/superseedr-private` removes the installed package.
Application configuration and downloaded media are not managed by this tap.

## Maintenance

See [the maintainer guide](docs/maintaining.md) for CI, bottle publication,
automatic release PRs, required credentials, and adding another project.
See [validation status](docs/validation.md) for what has actually been tested.
