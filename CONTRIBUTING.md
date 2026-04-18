# Contributing

Thank you for contributing to this project! Follow the engineering workflow in `AGENTS.md` for every task. The summary below highlights the key steps.

## Quick Start

1. **Sync main:** `git checkout main && git pull origin main`
2. **Create branch:** `git checkout -b <category>/<description>` (e.g., `feat/add-tool`, `fix/dockerfile-issue`)
3. **Make changes:** Edit code, configs, and documentation as needed
4. **Verify:** Build and test locally with podman (see AGENTS.md step 5)
5. **Commit:** Use conventional format (e.g., `git commit -m "feat(dockerfile): add new tool"`)
6. **Push:** `git push -u origin <your-branch>`
7. **PR:** Create a pull request with `gh pr create` (write an explicit title and body)
8. **Cleanup:** After merge, delete local and remote branches (see step 9 in AGENTS.md)

**For full details, see `AGENTS.md`.**

If anything is unclear, please ask before proceeding.

---

## Branch Naming

Use the format `<category>/<short-description>`:

| Category | When to use |
|----------|-------------|
| `feat` | new feature or capability |
| `fix` | bug fix |
| `chore` | maintenance, dependency updates, tooling |
| `docs` | documentation-only changes |
| `refactor` | code restructuring without behavior change |
| `ci` | CI/CD pipeline changes |

---

## Conventional Commits

Write commits in [conventional commit](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <short summary>

[optional body explaining the why, not the what]

[optional footer: issue refs, breaking changes]
```

**Examples:**
- `fix(dockerfile): correct nodejs package name casing`
- `feat(dockerfile): add helm binary via multi-stage build`
- `chore(deps): bump kubectl to v1.36.0`
- `ci(trivy): fail on HIGH as well as CRITICAL vulnerabilities`

---

## Dependabot Configuration

This repository uses [Dependabot](https://docs.github.com/en/code-security/dependabot) to keep Docker base images and GitHub Actions workflows up to date automatically.

**When updating dependencies:**
1. Edit `.github/dependabot.yml` to include the relevant package ecosystem (e.g., `docker`, `github-actions`)
2. Verify the local build passes with the new versions
3. Commit with `chore(deps): ...` format

**Example dependabot.yml entry:**

```yaml
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

Dependabot will create pull requests automatically when updates are available. No manual action is needed unless you want to change the update schedule.
