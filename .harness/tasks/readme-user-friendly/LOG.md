# LOG.md — README 사용자 친화 개편 로그

## 2026-07-08

- 루트 `.harness/STATE.md`에 README 사용자 친화 개편 목표가 기록돼 있었으나,
  해당 작업은 별도 Task 없이 시작된 뒤 중단됐다.
- 이번 `4.12`에서는 해당 문구를 루트 템플릿에서 제거하고 이 Task별 디렉토리로 이관했다.
- README 개편은 후속 Task로 남긴다.

## 2026-07-08

- `4.13` README 사용자 친화 개편 Task를 planning proposal로 추가했다.
- proposal 검증, 적용, `tasks/index.json`/`Plans.md` sync 검증을 통과했다.
- `4.13` 상태를 `wip`로 전환하고 README 편집을 시작한다.
- README 앞부분에 `먼저 고를 것`, `Quick Start`, `Codex CLI Setup`, `작업별 Workflow`를 추가하고 기존 중복 Quick Start를 제거했다.
- 기존 `Troubleshooting`에 Codex command/quality-gate 관련 항목을 보강했다.
- Acceptance는 통과했고, 감지된 프로젝트 테스트 스위트는 없어 skip했다.
