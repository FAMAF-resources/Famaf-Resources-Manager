![GitHub Repo Size](https://img.shields.io/github/repo-size/FAMAF-resources/Famaf-Resources-Manager)

# Famaf-Resources-Manager

In this repository we hold the shared workflows of the Famaf-Resources organization, and have automatic updates so they can be easily updated.

Every time this repo is updated, a dispatch action is issued and all the repos that are listed in the `.github/workflows/repositories.json` file (`child-repos`) are notified by trigger and updated. To add or remove a child repository, edit that file only.

Two separate GitHub Apps are used, so each one holds the minimum permissions. No personal access token is needed.

| Role | App | Permissions | Secrets | Where |
|---|---|---|---|---|
| Dispatcher | **Student-Kernel-GOAT** | Contents: write | `FRM_APP_ID`, `FRM_APP_PRIVATE_KEY` | this repo |
| Updater | a second app (to be created) | Contents: write, Workflows: write | `UPDATER_APP_ID`, `UPDATER_APP_PRIVATE_KEY` | each child repo (or org secrets limited to them) |

The dispatcher requests a token scoped to each target repository. The updater (`update_submodules`) pushes the synced files, including `.github/workflows`, to its own repository only. When the updater app exists, only its ID and private key need to be set in those secrets; no workflow changes are required. Until then `update_submodules` fails at the token step in the children.

### Protecting `main` of this repo

Children execute code from this repo, so `main` must be protected. [`.github/CODEOWNERS`](.github/CODEOWNERS) defines the owners, and [`.github/rulesets/protect-main.json`](.github/rulesets/protect-main.json) is a ruleset to import (Settings → Rules → Rulesets → Import): PR required, code owner review, required checks (`actionlint`, `zizmor`, `repositories.json`), no force pushes or deletion. Repository admins can bypass through a pull request.

## Features

- [x] Update to child repositories from parent (submodule)
- [x] Labeler
- [x] Auto assign PR
- [x] Greetings on PR's and issues
- [x] Structure validation of the files added by a PR (`validate_structure.yml`, `scripts/validate_structure.sh`)
- [x] Thanks message when the first PR of a contributor is merged (`thanks_first_merge.yml`)
- [x] PR and issue templates, and a `CONTRIBUTING.md` for contributors
- [x] Workflow linting (`actionlint`) and `repositories.json` validation in this repo

Everything in `child.github/` is copied to `.github/` of the child repositories by `scripts/update_w_from_parent.sh`.

## Security conventions

- Every workflow declares `permissions: {}` at the top and grants only what each job needs.
- Third party actions are pinned to a commit SHA (the version is kept in a comment).
- `actionlint`, `zizmor`, `shellcheck` and a check of `repositories.json` (existence, not archived) run on every change.

### Forks and permissions

- Triage workflows (labeler, auto-assign, greetings, thanks) use `pull_request_target` with a scoped `GITHUB_TOKEN`. They never check out PR code, so they work on PRs from forks and need no secrets.
- Only `update_submodules` (children) and `dipatch` (parent) use the GitHub App. Both are guarded by owner/repository, so they do nothing in forks.
- The app needs **Contents: write** and **Workflows: write**. Requesting `permission-*` in a workflow is not a security boundary: the real limits are the app's installation permissions, secrets restricted to selected repos / a `main`-only environment, and branch protection with CODEOWNERS on this repo's `main` (children run code from it).
- `validate_structure` rejects PRs that touch `.github/`, `.gitmodules` or the `Famaf-Resources-Manager` submodule, and symlinks or new submodules. Those paths are managed by this repo.
- Recommended org settings: default workflow token read-only, approval required for workflows from outside collaborators, and a ruleset making the checks required (a PR can modify its own workflow files).

## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

**You are free to**

*Share* — copy and redistribute the material in any medium or format
*Adapt* — remix, transform, and build upon the material

The licensor cannot revoke these freedoms as long as you follow the license terms.

**Under the following terms**

*Attribution* — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.

*NonCommercial* — You may not use the material for commercial purposes.

*ShareAlike* — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

*No additional restrictions* — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

# Contributors
<a href="https://github.com/FAMAF-resources/Famaf-Resources-Manager/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FAMAF-resources/Famaf-Resources-Manager" height='50'/>
</a>
