# remote-terminal

Sets up the laptop so the phone can open a terminal on it (OpenSSH key-only, Tailscale, tmux). Private: names the laptop user and setup details.

Maintenance: `tools/quality_gate.sh` is the gate; `tools/pipeline-check.sh` (program: github.com/yujideluca/pipeline-check,
pinned in `pipeline-check.version`) runs it with the fitness checks and CI runs the same. Enable the local pre-push check with
`git config core.hooksPath tools/hooks`.
