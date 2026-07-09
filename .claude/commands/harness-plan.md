---
description: PRD·기획 문서를 Task proposal로 분해하고 검증 후 tasks/index.json에 반영한다.
---

# /harness-plan

절차 원본은 `.agents/skills/harness-plan/SKILL.md`다. 이 command는 Claude Code 호출용 wrapper다.

1. `.agents/skills/harness-plan/SKILL.md`를 읽고 같은 절차를 따른다.
2. proposal 검증(`validate_task_proposal.py`) 통과 전에는 `tasks/index.json`을 수정하지 않는다.
3. `Plans.md`는 직접 편집하지 않는다 — `sync_plans.py`로만 재생성한다.
4. 인자: `$ARGUMENTS` (기획 문서 경로 또는 분해 대상 설명)
