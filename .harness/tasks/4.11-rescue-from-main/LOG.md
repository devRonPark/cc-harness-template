# LOG.md — Task 4.11 작업·에러 로그

## 2026-07-08

- planning proposal 절차로 Task `4.11`을 추가하고 완료 처리했다.
- Claude Code local custom command `.claude/commands/rescue-from-main.md`와
  Codex repo-scoped skill `.agents/skills/rescue-from-main/SKILL.md`를 추가했다.
- 절차는 preflight, diff 기반 branch slug 생성, `main`/`master` uncommitted 변경의
  `git switch -c` 보존, local commit 자동 reset 금지, commit/push/draft PR 본문
  규칙을 포함한다.
- `AGENTS.md`, `README.md`, `BLUEPRINT.md`, `.harness/CONTEXT_INDEX.md`에 새 helper를
  등록했다. `init.sh`는 `.agents/skills/`와 `.claude/commands/` 전체 복사라 새 파일이
  자동 포함됨을 smoke test로 확인했다.
- `.agents/skills/rescue-from-main` 디렉터리 생성은 샌드박스 read-only 제한으로
  최초 `mkdir -p`가 실패했고, 승인된 escalated command로 생성한 뒤 `apply_patch`로
  파일을 추가해 해결했다.
