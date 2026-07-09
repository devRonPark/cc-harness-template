---
description: harness/template 구조를 solo-builder 기준으로 점검하고 과한 복잡도를 줄인다.
---

# /harness-yagni-trimmer

절차 원본은 `.agents/skills/harness-yagni-trimmer/SKILL.md`다. 이 command는 Claude Code 호출용 wrapper다.

1. `.agents/skills/harness-yagni-trimmer/SKILL.md`를 읽고 같은 절차를 따른다.
2. `agents/quality-gates.md`의 YAGNI 기준을 적용한다.
3. 제거 제안은 근거(사용처 없음, 중복, 미참조)를 파일 경로와 함께 제시한다.
4. 인자: `$ARGUMENTS`
