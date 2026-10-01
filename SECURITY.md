# Security Policy

## Supported versions

Only the image built from the current `main` branch (the `latest` tag) is supported. Older tags and digests do not receive fixes.

## Reporting a vulnerability

Please **do not** open a public issue or pull request for security problems.

Report privately through GitHub: open the repository's **Security** tab and choose **Report a vulnerability** (private vulnerability reporting). Include what you found, how to reproduce it, and which file or image layer is affected.

This is a personal project maintained on a best-effort basis, so there is no guaranteed response time. Reports are acknowledged as soon as practical.

## Scope

In scope: the `Dockerfile`, `scripts/`, and the GitHub Actions workflows in this repository.

Out of scope:

- vulnerabilities in upstream packages (Ubuntu, HashiCorp, AWS, Kubernetes) that have no fix available yet; report those upstream. Known CVEs are tracked through the Trivy scans in CI.
- the intended behaviour of this image as an admin toolbox, see the "Intended use" section in the README.
