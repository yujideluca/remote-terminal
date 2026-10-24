# Automated bug-finding tests: remote-terminal

Last reviewed: 42253a0 2026-10-24
Created by the skill `gerar-teste-automatizado` (create mode).

## Analysis summary
One root-only Bash script (`setup-sudo.sh`) that configures OpenSSH (key only, one user, no root), Tailscale and tmux. It changes the system (sshd, apt, authorized keys), so it cannot be run as a test on the laptop without changing the laptop.

## Test matrix
Not applicable beyond static checks: `bash -n` on every script (done by the gate) and `shellcheck` when installed (CI has it). Not testable here: the effect on sshd, apt and Tailscale.

## Results (observed, 2026-10-24)
Gate and CI pass. `shellcheck` is not installed on the laptop; CI runs it with the project's own script.

## Defects found
None by static checks. Not verified: idempotence of a second run, and that a malformed key argument is refused (the script has the check; no automated test).

## Limitations and residual risks
A behavioural test needs a throwaway machine (container or VM): residual risk for lock-out of the SSH key rules.

## Recommendations
1. Test the script in a container with `systemd` (or a VM) twice in a row and assert the sshd configuration and `authorized_keys` after each run.
2. Install `shellcheck` on the laptop so the gate checks it locally too (needs sudo: `sudo apt install shellcheck`).
