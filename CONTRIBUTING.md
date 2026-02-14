# Contributing

## Keeping GitHub Actions Up to Date

This repository uses Dependabot to automatically update GitHub Actions workflow dependencies. To contribute to this process or adjust the configuration:

1. Edit `.github/dependabot.yml` to add or modify the `github-actions` package ecosystem.
2. Use a dedicated branch for changes (e.g., `chore/dependabot-github-actions`).
3. Use a conventional commit message (e.g., `chore(dependabot): add github-actions ecosystem`).
4. Update documentation as needed (README, AGENTS.md).
5. Push your branch and open a pull request to `main`.

**Example dependabot.yml entry:**

```yaml
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

If you have questions or something is unclear, please ask before proceeding.
