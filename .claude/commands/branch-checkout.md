---
description: Create or switch to a dedicated task branch after checking repository state.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git switch:*), Bash(git fetch:*), Read
---

# /branch-checkout

절차 원본은 `.agents/skills/branch-checkout/SKILL.md`다. 이 command는 Claude Code 호출용 wrapper다.

1. `.agents/skills/branch-checkout/SKILL.md`를 읽고 같은 절차를 따른다.
2. `git status --short`와 `git branch --show-current`를 먼저 확인한다.
3. 사용자 변경은 되돌리지 않는다.
4. `git reset --hard`, `git checkout --`, 강제 push는 실행하지 않는다.
5. 인자: `$ARGUMENTS`
