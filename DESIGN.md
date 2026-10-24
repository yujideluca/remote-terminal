# remote-terminal: design

Last updated: 2026-10-24

## 1. What it is
One idempotent root script (`setup-sudo.sh`) that installs and hardens what the phone terminal needs; see the wiki page `remote-terminal`.

## 2. Decision log

| Date | Type | Decision | Why |
|---|---|---|---|
| 2026-10-24 | Preventive | **Put under git on GitHub (private) with a gate and CI** (`pipeline-check`, local pre-push check) | Standard of Giovanni's systems: every project is a versioned GitHub repository. The folder had no history and no check at all |
