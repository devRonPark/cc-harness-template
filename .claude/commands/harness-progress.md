---
description: tasks/index.json 기준으로 진행 상황을 읽기 전용 요약한다.
allowed-tools: Bash(python3 scripts/report_tasks.py:*), Bash(python3 scripts/sync_plans.py --check:*), Bash(grep:*), Read
---

# /harness-progress

절차 원본은 `.agents/skills/harness-progress/SKILL.md`다. 이 command는 Claude Code 호출용 wrapper다.

1. `.agents/skills/harness-progress/SKILL.md`를 읽고 같은 절차를 따른다.
2. `python3 scripts/report_tasks.py`로 요약한다. `tasks/index.json` 전체를 Read 하지 않는다.
3. Task 상태를 바꾸지 않고, 요청 없이 `Plans.md`를 재생성하지 않는다.
4. 인자: `$ARGUMENTS`
