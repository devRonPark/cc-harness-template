---
description: tasks/index.json을 검증하고 Plans.md snapshot을 재생성한다.
allowed-tools: Bash(python3 scripts/validate_tasks.py:*), Bash(python3 scripts/sync_plans.py:*), Read
---

# /harness-sync

절차 원본은 `.agents/skills/harness-sync/SKILL.md`다. 이 command는 Claude Code 호출용 wrapper다.

1. `.agents/skills/harness-sync/SKILL.md`를 읽고 같은 절차를 따른다.
2. `validate_tasks.py` 통과 후에만 `sync_plans.py`를 실행하고, `--check`로 동기화를 확인한다.
3. `Plans.md`는 생성물이다 — 직접 편집하지 않는다.
4. 인자: `$ARGUMENTS`
