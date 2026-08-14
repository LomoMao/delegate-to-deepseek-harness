# Security

This skill can delegate work to an agent that edits files and runs shell commands. That is the main trust boundary.

## Safer defaults

- Keep Harness MCP endpoints on `127.0.0.1` unless you have added real authentication and transport security.
- Restrict worker workspace roots when the MCP bridge supports it.
- Review third-party Harness plugins before installing them. They run as local code inside the Harness process.
- Do not pass secrets in task prompts or commit them to repo-local config.
- Keep deployment, publishing, billing, credential rotation, destructive Git operations, and other irreversible actions outside delegated worker scope unless the user explicitly authorizes them and the host environment has appropriate approvals.

## Reporting a vulnerability

Please avoid filing a public issue for an exploitable vulnerability. Use GitHub's private vulnerability reporting if it is enabled for the repository. If it is not enabled, contact the maintainer privately through the repository owner's public contact method.

This repository does not provide a security boundary around DeepSeek Harness or third-party MCP plugins; it provides workflow guidance on top of them.
