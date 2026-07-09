# LOG.md — Task 작업·에러 로그

## 2026-07-09

- Context Budget Audit 수행: harness-work 루프가 step 1에서 ~62.9KB
  (AGENTS 5.6 + CLAUDE 7.3 + quality-gates 4.0 + index.json 22.1 + Plans.md 15.8
  + LESSONS 7.5), step 3에서 task-decomposer 10.9KB, step 10 리뷰에서 규칙 문서
  16.9KB를 재독 — 루프당 규칙/상태 문서 약 94KB 로드로 측정.
- 패치 적용: harness-work/review/plan/progress/sync SKILL 읽기 지시 축소,
  CLAUDE.md·AGENTS.md·README.md·CONTEXT_INDEX(루트+skeleton) 재개 순서 갱신,
  LESSONS.md(루트+skeleton) cap 8개 rewrite 규칙, HANDOFF/TASKS/CHECKPOINTS
  템플릿 헤더를 "필요 시 복사"로 정정.
- 에러 1건: 검증 중 `python -m pytest` 실패 (No module named pytest) —
  `pip install pytest` 후 18 passed. 환경 문제이며 코드 문제 아님.
