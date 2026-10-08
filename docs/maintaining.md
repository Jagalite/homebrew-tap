# Maintaining the tap

## CI and bottles

The workflows follow Homebrew's `brew tap-new` templates. Pull requests run
`brew test-bot` on macOS 15 ARM64, macOS 15 Intel, and x86_64 Linux. It validates
tap syntax, builds changed formulae, runs their tests, and produces real
Homebrew bottles and bottle JSON metadata. Pushes to `main` validate tap syntax;
use a pull request for every new formula and source change so bottles are built.
Workflow-only changes may correctly produce no bottle artifacts.

After every matrix job passes, review the PR and record its exact head SHA.
**Do not merge the formula PR with GitHub's merge button first.** Publish using:

```sh
gh workflow run publish.yml --repo Jagalite/homebrew-tap \
  -f pull_request=123 -f head_sha=REVIEWED_40_CHARACTER_COMMIT_SHA
```

The `brew pr-pull` workflow verifies the reviewed head, retrieves CI artifacts,
publishes bottles to this public repository's GitHub Releases, commits the
merged bottle checksums, adds build attestations, and pushes `main`. Homebrew
then downloads matching bottles automatically. Review is intentional; release
checks automate update PRs, not unattended acceptance of upstream source.
Never invent bottle checksums or advertise bottles before the publish job
succeeds. If CI artifacts have expired, rerun the PR checks before publishing.

This uses GitHub Releases, not GHCR; users need no registry credentials. Bottle
jobs use Homebrew's default CPU baseline. Do not add `target-cpu=native`.

## Released-version automation

`autobump.yml` checks every formula hourly (at minute 17 UTC), on manual dispatch,
and on the `upstream-release` repository dispatch. `superseedr-private` explicitly
uses `livecheck`'s `github_latest` strategy: only the latest published stable
GitHub release is eligible, not arbitrary tags or prereleases. `brew bump`
calculates the new archive checksum, removes stale bottle metadata, and opens a
version PR. Existing current-version formulae are a no-op; Homebrew detects
existing bump PRs. CI must pass before publishing the update and its bottles.

The Superseedr integration is `.github/workflows/homebrew-tap.yml` in the
Superseedr repository. It sends a dispatch after a release is published. It
also listens for successful `Rust` workflow completions from pushes: the
existing release workflow uses `GITHUB_TOKEN`, whose release event cannot
start another workflow. The extra notification after a non-release build is
harmless because the tap always checks published release metadata. No code or
artifacts from that run are executed by the notification workflow.

The hourly poll recovers missed notifications and failed upstream workflows.
GitHub may delay scheduled runs or disable schedules on inactive public repos;
monitor Actions and re-enable schedules if needed. Manual retry:

```sh
gh workflow run autobump.yml --repo Jagalite/homebrew-tap
```

## Credentials and repository settings

Installation and public source downloads need **no credentials**.

| Location | Secret | Permissions and purpose |
| --- | --- | --- |
| `Jagalite/homebrew-tap` | `TAP_UPDATE_TOKEN` | Fine-grained PAT restricted to this tap: Contents read/write and Pull requests read/write. Its owner needs write access. Creates update branches/PRs that trigger CI. |
| `Jagalite/superseedr` | `HOMEBREW_TAP_TOKEN` | Fine-grained PAT restricted to `Jagalite/homebrew-tap`: Contents read/write, to send repository dispatch events. |
| Tap CI and publishing | `GITHUB_TOKEN` | Automatically provided by Actions; job permissions are declared in YAML. No manual secret required. |

Use separate narrowly scoped, expiring tokens. Enter them through GitHub's
Actions secrets settings or `gh secret set`'s interactive prompt; never put them
in formulae, URLs, workflow files, or commit history. Do not substitute the tap's
`GITHUB_TOKEN` for `TAP_UPDATE_TOKEN`: PRs created with it do not automatically
trigger the required PR CI. A GitHub App installation token can replace the PAT
if an installation-token generation step is added.

```sh
gh secret set TAP_UPDATE_TOKEN --repo Jagalite/homebrew-tap
gh secret set HOMEBREW_TAP_TOKEN --repo Jagalite/superseedr
```

Enable Actions in both repositories. Allow the tap's publishing workflow to
write contents, pull requests and attestations, and request an OIDC token.
Branch protections/rulesets must permit the reviewed publishing workflow to
push its bottle commit to `main`; do not bypass protections ad hoc. If policy
forbids this, adapt the publication flow before attempting a release.

For manual `gh` operations, authenticate with repository write access and
Actions write access for workflow dispatch. Creating/updating workflow files
with a token additionally requires Workflows write (or the classic `workflow`
scope). CI never needs access to a private Superseedr repository.

## First publication from an empty repository

1. Publish the tap infrastructure to `main` with no formula yet. This establishes
   a default branch and makes the publishing workflow available.
2. Open a PR adding `Formula/superseedr-private.rb` from this checkout. Keeping
   the first formula in a PR ensures `brew test-bot` builds its initial bottles.
3. Configure the two secrets above and publish the Superseedr notification
   workflow to that repository's default branch. The hourly poll works without
   the upstream notifier once `TAP_UPDATE_TOKEN` is configured.
4. Wait for the formula PR's entire matrix, review its head SHA, and run
   `publish.yml` as described above. Verify a fresh remote bottle installation
   before announcing remote availability.

## Add another project

Add `Formula/<name>.rb` with a unique formula class, description, homepage,
versioned source URL, verified SHA-256, license, build dependencies, installation
method, and an isolated noninteractive `test do` block. Add a `livecheck` block
that reflects that project's release policy and list it in the README table.
Use a distinct executable name when variants would otherwise collide.

No CI matrix or autobump allowlist needs editing: both discover tap formulae.
An upstream may send the same `upstream-release` dispatch after publishing; the
tap checks its own formula metadata instead of trusting payload URLs or code.

Local checks, from an installed development tap:

```sh
brew style Jagalite/tap/<name>
brew audit --strict Jagalite/tap/<name>
brew install --build-bottle Jagalite/tap/<name>
brew test Jagalite/tap/<name>
brew bottle --json Jagalite/tap/<name>
```

Also lint workflow changes with `actionlint`. After uninstalling only the package
you just built, reinstall the local bottle and run `brew test` again. Homebrew 7
requires developer mode for a local archive path, and uninstalling can remove
the formula's trust entry:

```sh
brew trust --formula Jagalite/tap/<name>
HOMEBREW_DEVELOPER=1 brew install /absolute/path/to/package.bottle.tar.gz
brew test Jagalite/tap/<name>
```

Use the exact filename emitted by `brew bottle`. Confirm `poured_from_bottle`
is `true` in the installed keg's `INSTALL_RECEIPT.json`. Do not commit local bottle archives; CI artifacts
and GitHub Releases hold the distributable files.

References: [tap maintenance](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap),
[bottle format and lifecycle](https://docs.brew.sh/Bottles), and
[GitHub workflow triggering rules](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).
