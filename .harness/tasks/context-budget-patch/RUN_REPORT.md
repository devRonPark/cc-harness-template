# RUN_REPORT.md — 변경·결정·검증 요약

## 변경 요약

harness-work 루프의 토큰 소모를 줄이기 위해 스킬/규칙 문서의 "읽기 지시"를
선택적 로드로 변경. 기능 동작(게이트·TDD·검증·리뷰 순서, 스크립트)은 불변.

- Task 선택: `tasks/index.json` 전체 Read → `report_tasks.py` 요약 +
  `grep -n -A12 '"id": "<task-id>"'` 블록 읽기
- `Plans.md`: 루프 읽기 목록 전부에서 제거 (사람용 생성물, 쓰기 전용)
- 규칙 문서(AGENTS/CLAUDE/quality-gates): 세션 내 재독 금지 (리뷰 단계 포함)
- `task-decomposer.md`: 1차 게이트 통과 시 로드 생략, 미달 의심 시만 전체 읽기
- `LESSONS.md`: 최근 5개만 읽기 + 최대 8개 유지 rewrite 규칙 (append 누수 차단)
- Task 디렉토리: 템플릿 복사 6종 → 3종(STATE/LOG/RUN_REPORT)

## 주요 결정 근거

- done Task 아카이브 분리는 sync_plans/plans-guard 계약 변경이 필요해 스코프 제외.
- `.harness/context/`·`index/` 신규 디렉토리는 기존 CONTEXT_INDEX/STATE/LESSONS가
  같은 역할이므로 미도입 (문서 증식 금지).
- grep 블록 패턴은 LESSONS.md 2026-07-08 항목의 기존 검증 패턴 재사용,
  depends 배열 다중 행 대비 `-A8` → `-A12`.

## Evidence

| 항목 | 명령 | 결과 |
|---|---|---|
| TDD | - | 예외: 문서/규칙 변경만, 런타임 코드·스크립트 무변경 (CLAUDE.md TDD 예외 조항) |
| 구조 검증 | `python3 scripts/validate_tasks.py` | PASS (47 tasks) |
| Sync 검증 | `python3 scripts/sync_plans.py --check` | PASS (Plans.md 미변경) |
| 테스트 스위트 | `python3 -m pytest tests/ -q` | PASS (18 passed) |
| grep 패턴 | `grep -n -A12 '"id": "4.19"' tasks/index.json` | 단일 블록 온전 출력 |

## 루프 로드 Before/After (harness-work step 1~3 기준, 추정)

- Before: AGENTS 5.6 + CLAUDE 7.3(재독) + quality-gates 4.0 + index.json 22.1
  + Plans.md 15.8 + LESSONS 7.5 + decomposer 10.9 = 약 73KB, 리뷰 재독 +16.9KB
- After: quality-gates 4.0 + report_tasks.py 출력(<1KB) + Task grep 블록(<0.5KB)
  + LESSONS 최근 5개(~5KB 상한) + STATE.md(~0.6KB) = 약 10~11KB, 리뷰 재독 0
- 약 85% 감소 (추정치, 토큰 실측 아님)

## 남은 위험 / 후속 후보

- done Task가 index.json에 계속 누적 (현재 47개 전부 done) — 아카이브 분리는
  후속 Task로 (sync_plans/plans-guard 계약 동반 변경 필요).
- `.harness/shared/planning/runs/` retention 미설정 — 현재 1KB 미만, 누적 관찰 후 판단.
- grep -A12는 Task 객체가 12행을 넘으면(긴 depends) 잘릴 수 있음 — 잘리면 -A 값을
  늘려 재실행하면 됨.
