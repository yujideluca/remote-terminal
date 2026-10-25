# remote-terminal: design

Last updated: 2026-10-25

## 1. What it is
One idempotent root script (`setup-sudo.sh`) that installs and hardens what the phone terminal needs; see the wiki page `remote-terminal`.

## 2. Decision log

| Date | Type | Decision | Why |
|---|---|---|---|
| 2026-10-25 | Preventive | **Monthly architecture review**: pipeline-check v0.4.0, local mode, report of 2026-10-25: 0 falhas, 0 avisos, 1 pulado (protecao-de-branch); 1 proposal; proposals created as pipeline-check#4 | Monthly review standard (ADR-0013): the program measures, the skill judges |
| 2026-10-24 | Preventive | **First maintenance review**: report ok; no test can run the script without changing the laptop (`docs/TESTES-AUTOMATIZADOS.md`); proposals not yet created as issues: P2 test the script twice in a container, P3 install shellcheck locally (sudo) | Standard first review of a project that now has a gate |
| 2026-10-24 | Preventive | **Put under git on GitHub (private) with a gate and CI** (`pipeline-check`, local pre-push check) | Standard of Giovanni's systems: every project is a versioned GitHub repository. The folder had no history and no check at all |
