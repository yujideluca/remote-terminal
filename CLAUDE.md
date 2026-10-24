# remote-terminal: working notes for Claude Code

`setup-sudo.sh` makes the laptop reachable from Giovanni's phone: OpenSSH (keys only, user yuji, no root), Tailscale, tmux.
Safe to re-run. Needs sudo, so Giovanni runs it himself (`sudo bash ~/dev/remote-terminal/setup-sudo.sh`).

- Gate: `tools/quality_gate.sh` (syntax of the shell scripts); full measurement `tools/pipeline-check.sh`. After pushing, CI must be green.
- Never put keys, passwords or tokens in this repository. Never force-push. Ask Giovanni before anything outward-facing.
- Decisions go in `DESIGN.md` (decision log with Type). At the end of a task update the wiki (`wiki publish`), then `mem use`.
