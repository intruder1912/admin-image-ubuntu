# AGENTS.md

## Learnings: Dependabot and GitHub Actions

- When updating dependencies, always include `github-actions` as a package ecosystem in `.github/dependabot.yml` to ensure GitHub Actions workflows are kept up to date.
- Use a dedicated branch for each change, following the format: `<category>/<short-description>` (e.g., `chore/dependabot-github-actions`).
- Use conventional commit messages for clarity and traceability.
- Update documentation (README, contributing guide, AGENTS.md) with concise, non-redundant, audience-appropriate content and working examples.
- After making changes, push the branch and open a pull request to `main`.
- If anything is unclear, always ask for clarification before proceeding.

## Example: Dependabot Configuration for GitHub Actions

```
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

This ensures that GitHub Actions workflow dependencies are automatically checked and updated by Dependabot.
