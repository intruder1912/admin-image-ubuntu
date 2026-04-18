@AGENTS.md

## Claude Code Optimizations

When working in Claude Code:

- **Prefer dedicated tools over Bash:** Use `Read` for file contents, `Edit` for modifications, `Grep` for searches, and `Glob` for file patterns. Reserve Bash for system commands and terminal operations that require shell execution.
- **Use `podman` on macOS:** All container operations must use `podman`, not `docker`. This is especially important in the Verify step (step 5).
- **Read files before editing:** Always read a file with the `Read` tool before making changes with `Edit` to ensure you understand the full context.
