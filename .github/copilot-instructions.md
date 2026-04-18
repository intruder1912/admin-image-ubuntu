# GitHub Copilot Instructions

The authoritative engineering workflow is in `AGENTS.md`. The checklist below mirrors that workflow and provides Copilot-specific context for code completion, suggestions, and PR reviews.

## Project Context

This is a **multi-stage Dockerfile-based Ubuntu image** for admin/DevOps tooling:
- **Target:** ARM64 macOS (`--platform="linux/arm64"`)
- **Entrypoint:** zsh
- **User:** non-root (`intruder`, UID 1001)
- **Purpose:** portable admin workstation with Kubernetes, Terraform, AWS CDK, AWS CLI, and network admin tools

When suggesting code:
- Favor multi-stage builds for size optimization
- Maintain non-root execution
- Use conventional commit messages throughout

---

## Engineering Workflow Checklist

### 1. Sync with main
```sh
git checkout main && git pull origin main
```

### 2. Create feature branch
Use `<category>/<description>` naming: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `ci/`
- Example: `feat/add-helm-tool`, `fix/dockerfile-syntax`, `chore/bump-kubectl`

### 3. Understand the task
- Read relevant files and context
- Ask for clarification if anything is unclear

### 4. Implement changes
- Modify code, configs, and documentation
- Keep changes concise and non-redundant
- Update README, CONTRIBUTING, or AGENTS.md if the change affects usage or workflow

### 5. Verify locally (required before commit)
**On macOS, use `podman` not `docker`:**

```sh
# Build
podman build --platform="linux/arm64" -t localhost/adminubuntu:latest .

# Confirm
podman image ls localhost/adminubuntu:latest

# Smoke test (all three must succeed)
podman run --rm localhost/adminubuntu:latest -c "kubectl version --client && terraform version && aws --version"
```

Do not proceed if any check fails. Re-run the full build.

### 6. Commit with conventional format
```sh
git add .
git commit -m "<type>(<scope>): <summary>

[optional body explaining why, not what]

[optional footer: issue refs, breaking changes]"
```

Examples: `fix(dockerfile):`, `feat(dockerfile):`, `chore(deps):`, `ci(trivy):`

### 7. Push branch
```sh
git push -u origin <branch-name>
```

### 8. Create PR
```sh
gh pr create --base main --head <branch-name> \
  --title "<type>(<scope>): <summary>" \
  --body "## Summary\n...\n## Testing\n...\n## Related\n..."
```

Do not rely on `--fill` alone — write an explicit title and body.

### 9. Post-merge cleanup
```sh
git checkout main && git pull origin main
git branch -d <branch-name>
git push origin --delete <branch-name>
```

---

## Dependabot & Dependency Updates

See `CONTRIBUTING.md` for dependency management details. When updating dependencies:
- Edit `.github/dependabot.yml` to include the correct package ecosystem (`docker`, `github-actions`, etc.)
- Verify the build passes with new versions
- Commit using `chore(deps): ...` format
