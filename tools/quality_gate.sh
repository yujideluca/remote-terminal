#!/usr/bin/env bash
# Quality gate: every shell script parses; shellcheck too when it is installed.
set -euo pipefail
cd "$(dirname "$0")/.."
for f in $(git ls-files '*.sh') tools/hooks/pre-push; do bash -n "$f"; echo "syntax ok: $f"; done
if command -v shellcheck >/dev/null; then git ls-files '*.sh' | xargs shellcheck -S warning; else echo "shellcheck not installed (skipped)"; fi
