# AGENTS.md

## Engineering Workflow Steps

Follow these steps in order for every engineering task:

### 1. Sync with origin/main

Always start from an up-to-date `main` branch:

```sh
git checkout main
git pull origin main
```

### 2. Create a feature branch

Branch off `main` immediately after syncing. Use the naming scheme `<category>/<short-description>`:

| Category | When to use |
|----------|-------------|
| `feat`   | new feature or capability |
| `fix`    | bug fix |
| `chore`  | maintenance, dependency updates, tooling |
| `docs`   | documentation-only changes |
| `refactor` | code restructuring without behaviour change |
| `ci`     | CI/CD pipeline changes |

```sh
git checkout -b <category>/<short-description>
# e.g.: git checkout -b feat/add-helm-tool
#        git checkout -b fix/nodejs-package-name
#        git checkout -b chore/bump-kubectl-version
```

### 3. Understand the task

Before writing any code:

- Read the relevant files and context.
- Clarify any ambiguity with the user before proceeding.
- If anything is unclear, always ask for clarification.

### 4. Implement the task

- Make all necessary code, config, and documentation changes.
- Update documentation (README, CONTRIBUTING, AGENTS.md) when the change affects usage, workflow, or project conventions. Keep content concise, non-redundant, and audience-appropriate.

### 5. Verify locally — required before committing, pushing, or opening a PR

**Do not proceed to the next step unless verification passes.**

#### Build the image

On macOS, use `podman` instead of `docker`:

```sh
podman build --platform="linux/arm64" -t localhost/adminubuntu:latest .
```

A successful build ends with output similar to:

```
Successfully tagged localhost/adminubuntu:latest
<sha256 digest>
```

#### Confirm the image exists

```sh
podman image ls localhost/adminubuntu:latest
```

#### Smoke-test the entrypoint

```sh
podman run --rm localhost/adminubuntu:latest -c "kubectl version --client && terraform version && aws --version"
```

All three commands must exit successfully. If any fail, fix the issue and re-run the full build before continuing.

#### If verification fails

- Fix the problem in the implementation.
- Re-run the build and smoke-test from the top of this step.
- Do **not** commit, push, or open a PR until all checks pass.

### 6. Commit with a conventional commit message

Stage all relevant changes and commit using the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<optional scope>): <short imperative summary>

<optional body: explain the why, not the what>

<optional footer: breaking changes, issue references>
```

Examples:

```sh
git add .
git commit -m "fix(dockerfile): correct nodejs package name casing"
git commit -m "feat(dockerfile): add helm binary via multi-stage build"
git commit -m "chore(deps): bump kubectl to v1.36.0"
git commit -m "ci(trivy): fail on HIGH as well as CRITICAL vulnerabilities"
```

### 7. Push the branch to origin

```sh
git push -u origin <your-branch-name>
```

### 8. Create a pull request with the GitHub CLI

Use `gh pr create` with an explicit, descriptive title and a structured body. Do **not** rely on `--fill` alone — write a useful title and body:

```sh
gh pr create \
  --base main \
  --head <your-branch-name> \
  --title "<type>(<scope>): <short summary>" \
  --body "$(cat <<'EOF'
## Summary

- <bullet: what changed and why>
- <bullet: any noteworthy implementation detail>

## Testing

- <how the change was verified locally>

## Related

- Closes #<issue-number> (if applicable)
EOF
)"
```

### 9. After a pull request is merged

Clean up once the PR is merged into `main`:

```sh
git checkout main
git pull origin main
git branch -d <branch-name>
git push origin --delete <branch-name>
```

If anything is unclear, always ask for clarification before proceeding.
