#!/usr/bin/env bash
# Quality gate: every shell script parses; shellcheck too when it is installed.
set -euo pipefail
cd "$(dirname "$0")/.."
for f in $(git ls-files '*.sh') tools/hooks/pre-push; do bash -n "$f"; echo "syntax ok: $f"; done
# Only the project's own script is linted; tools/ is the shared runner.
if command -v shellcheck >/dev/null; then shellcheck -S warning setup-sudo.sh; else echo "shellcheck not installed (skipped)"; fi
