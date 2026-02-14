# AGENTS.md

## Engineering Workflow Steps

These steps apply to all engineering work:

- Use a dedicated branch for each change, named `<category>/<short-description>` (e.g., `chore/dependabot-github-actions`).
- Use conventional commit messages for clarity and traceability.
- Update documentation (README, contributing guide, AGENTS.md) with concise, non-redundant, audience-appropriate content and working examples.
- After making changes, push the branch and open a pull request to `main`.
- After a pull request is merged:
  1. Switch back to the `main` branch: `git checkout main`
  2. Pull the latest changes: `git pull origin main`
  3. Delete the local feature branch: `git branch -d <branch-name>`
  4. Delete the remote feature branch: `git push origin --delete <branch-name>`
- In the future, use the GitHub CLI (`gh`) to create and merge pull requests for a more streamlined workflow.

If anything is unclear, always ask for clarification before proceeding.

---

## Learnings: Dependabot Configuration

When updating dependencies, always include the relevant package ecosystem (e.g., `github-actions`) in `.github/dependabot.yml` to ensure workflows and dependencies are kept up to date.

**Example dependabot.yml entry:**

```yaml
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```
