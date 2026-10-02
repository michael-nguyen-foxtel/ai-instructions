# Personal GitHub Accounts

Which repos are personal, and how to run `gh` API commands against them when the ambient `GITHUB_TOKEN` defaults to the work account.

## The problem

`GITHUB_TOKEN` is injected into the agent environment as the **work** account (`michael-nguyen-foxtel`) and, per `gh`'s precedence rules, overrides the keyring for bare `gh` commands. Personal repos aren't collaborator-accessible to the work token → `gh pr create` etc. fail with `must be a collaborator`. Git push is unaffected (it uses the `github.com-personal` SSH remote).

## Personal accounts

| Account | Repos |
|---|---|
| `MichaelNguyen756` | `MichaelNguyen756/ai-workflow-skills` (public workflow repo) |

## The rule

Before any `gh` command that hits the **API** (PR/issue/release create, `gh api`, review) in a repo whose `origin` owner is in the table above, mint and pass the personal token explicitly:

```bash
GH_TOKEN=$(gh auth token --user MichaelNguyen756) gh pr create ...
```

- `gh auth token --user <acct>` reads the keyring OAuth creds directly — PAT-free, works even with `GITHUB_TOKEN` ambient.
- `GH_TOKEN` outranks `GITHUB_TOKEN`, so the single command runs as the personal account; nothing global changes.
- **Check `origin` owner first** (`git remote get-url origin`); only override when it matches a personal account.
- **Git operations (push/pull) need no override** — SSH handles identity.

## Setup (one-time, already done)

`env -u GITHUB_TOKEN gh auth login --hostname github.com --git-protocol https --web` as the personal account, git-credential step skipped.
