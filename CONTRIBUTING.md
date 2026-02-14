# Contributing

## Engineering Workflow Steps

These steps apply to all contributions:

1. Use a dedicated branch for each change, named `<category>/<short-description>` (e.g., `chore/dependabot-github-actions`).
2. Use conventional commit messages for clarity and traceability.
3. Update documentation as needed (README, AGENTS.md, etc.).
4. Push your branch and open a pull request to `main`.
5. After a pull request is merged:
    - Switch back to the `main` branch: `git checkout main`
    - Pull the latest changes: `git pull origin main`
    - Delete the local feature branch: `git branch -d <branch-name>`
    - Delete the remote feature branch: `git push origin --delete <branch-name>`
6. For future PRs, you can use the GitHub CLI (`gh`) to create and merge pull requests for a more streamlined workflow.

If you have questions or something is unclear, please ask before proceeding.

---

## Dependabot Configuration and Updates

This repository uses Dependabot to automatically update dependencies, including GitHub Actions workflows and Docker base images.

To adjust Dependabot configuration, edit `.github/dependabot.yml` to add or modify the relevant package ecosystem (e.g., `github-actions`, `docker`).

**Example dependabot.yml entry:**

```yaml
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```
