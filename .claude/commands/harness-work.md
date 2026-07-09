---
description: todo Task 하나를 선택해 세분화 게이트 확인 후 구현, Acceptance, 테스트, 리뷰까지 진행한다.
---

# /harness-work

절차 원본은 `.agents/skills/harness-work/SKILL.md`다. 이 command는 Claude Code 호출용 wrapper다.

1. `.agents/skills/harness-work/SKILL.md`를 읽고 같은 절차를 따른다.
2. 최소 컨텍스트 원칙을 지킨다: `tasks/index.json` 전체 Read 금지 (`report_tasks.py` 요약 + Task grep 블록), `Plans.md` 읽기 금지, 이미 로드된 규칙 문서 재독 금지.
3. 완료 기준(fresh verification, TDD evidence, RUN_REPORT 기록)은 SKILL.md의 완료 기준을 따른다.
4. 인자: `$ARGUMENTS` (Task ID 지정 시 해당 Task 우선)
