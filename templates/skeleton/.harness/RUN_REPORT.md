# RUN_REPORT.md — Task 실행 요약 템플릿

> 루트 파일은 템플릿이다. 실제 보고서는 `.harness/tasks/<task-key>/RUN_REPORT.md`에 둔다.
> 원문 로그는 `LOG.md`에 남기고, 여기는 다음 세션이 읽을 증거만 남긴다.

## Summary

- Task: `[id]`
- 상태: `[done|blocked|needs-review|in-progress]`
- 변경: `[핵심 변경 1-3줄]`

## Evidence

| 명령 | 결과 | 비고 |
|------|------|------|
| `[acceptance command]` | `[PASS|FAIL|SKIP]` | `[핵심 출력 또는 이유]` |
| `[test command]` | `[PASS|FAIL|SKIP]` | `[핵심 출력 또는 이유]` |

## Notes

- 결정: `[결정과 근거. 없으면 없음]`
- 변경 파일: `[path — 이유]`
- 실패/복구: `[LOG.md 위치 또는 없음]`
- 다음 행동: `[이어갈 위치 또는 없음]`
- 최종 갱신: `YYYY-MM-DD HH:MM KST`
