---
description: 현재 diff를 Task, CLAUDE.md 규칙, Acceptance evidence 기준으로 코드 리뷰한다.
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(grep:*), Bash(python3 scripts/report_tasks.py:*), Read, Grep, Glob
---

# /harness-review

절차 원본은 `.agents/skills/harness-review/SKILL.md`다. 이 command는 Claude Code 호출용 wrapper다.

1. `.agents/skills/harness-review/SKILL.md`를 읽고 같은 절차를 따른다.
2. 이미 세션에 로드된 규칙 문서는 재독하지 않는다. 대상 Task 상세, Acceptance evidence, 현재 diff만 새로 읽는다.
3. 리뷰 중 직접 수정하지 않는다. 판정은 `APPROVE` / `REQUEST_CHANGES` 두 축(Spec compliance, Code quality) 기준.
4. 인자: `$ARGUMENTS` (대상 Task ID)
