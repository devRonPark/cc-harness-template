# [PROJECT_NAME] — CLAUDE.md

## 프로젝트 개요

**[프로젝트 한 줄 설명]**
[추가 컨텍스트 — 공모전, 고객사, 내부 툴 등]

## 기술 스택

- **런타임**: [Node.js / Python / Go / ...]
- **주요 프레임워크**: [...]
- **배포**: [...]
- **저장소**: [...]

## 디렉토리 구조

```
[project-name]/
├── src/
├── docs/
├── Plans.md
├── harness.toml
└── package.json (또는 pyproject.toml 등)
```

## 언어 규칙

- **모든 응답은 한국어로 작성한다.** 코드·명령어·고유명사는 그대로 유지.

## 코딩 규칙

- [프로젝트별 코딩 컨벤션 기입]
- [예: 함수 네이밍 규칙, import 순서, 에러 처리 방식 등]

## 기획 규칙

- **새 프로젝트/기능 착수 시 코드보다 먼저 `/grill-me`를 실행한다.**
  인터뷰 → `docs/PRD.md` 초안 → UserFlow·DESIGN·Architecture 보완 → `/harness-plan` 순서.
- 보완 문서 골격: `docs/templates/UserFlow.md`, `docs/templates/DESIGN.md`,
  `docs/templates/Architecture.md` 복사 후 작성.
- **UI가 있는 프로젝트는 DESIGN.md가 UI 구현의 single source of truth다.**
  UI 관련 Task는 Plans.md Depends에 DESIGN.md 작성 Task를 걸어 게이트한다 —
  worker가 색·간격·톤을 Task마다 즉흥 결정하지 않게 하기 위함. UI 없는
  프로젝트(CLI·라이브러리)는 DESIGN.md 생략.
- 기획 중 확정된 결정은 PRD의 Decisions 섹션에 근거와 함께 기록한다.
  ADR 별도 파일은 만들지 않는다 — 큰 결정이 쌓이면 그때 `docs/adr/`로 분리.
- **`/harness-plan`이 Plans.md에 Task 행을 쓰기 전, 반드시 `agents/task-decomposer.md`를
  먼저 실행한다.** PRD 핵심 기능을 바로 Task 행으로 옮기지 않는다 — 세분화 기준
  (agents/task-decomposer.md 참고)을 통과한 행 단위로만 Plans.md에 적는다.
  이 순서를 건너뛰고 뭉뚱그린 Task를 바로 적으면 안 된다.
- 이 단계는 harness 플러그인이 자동 실행하지 않는다 — Claude가 이 규칙에 따라
  세션에서 직접 수행한다 (테스트 규칙과 동일 패턴).

## 상태 문서 규칙

- **터미널 세션은 언제든 끊길 수 있다고 가정한다.** 작업 시작 전·작업 단위
  종료 후마다 `.harness/` 상태 문서를 갱신한다.
- **Task 상태의 단일 출처는 Plans.md다.** `.harness/`는 Plans.md가 담지 않는
  세션 맥락만 담는다 — Task 상태를 `.harness/`에 복제하지 않는다.
- 세션 재개 시 읽는 순서: `.harness/STATE.md` → `.harness/LESSONS.md`(최근 5개)
  → `Plans.md`. 나머지는 `.harness/CONTEXT_INDEX.md`로 필요한 파일만 선별해서
  읽는다 — 목적 없이 전체 파일을 다시 읽지 않는다.
- 파일별 역할: `STATE.md`(현재 스냅샷) · `HANDOFF.md`(다음 세션 인수인계) ·
  `TASKS.md`(현재 Task의 세션 체크리스트) · `LOG.md`(작업·에러 append-only) ·
  `LESSONS.md`(재발 방지) · `CHECKPOINTS.md`(작업 단위 완료 + 커밋 해시) ·
  `CONTEXT_INDEX.md`(파일 역할 인덱스).
- 에러는 숨기지 말고 `LOG.md`에 원문 기록, 해결하면 `LESSONS.md`에 재발 방지
  항목 추가. 항상 지킬 규칙으로 승격되면 이 파일(CLAUDE.md)에도 반영한다.
- 새 파일을 만들거나 기존 파일 역할이 바뀌면 `CONTEXT_INDEX.md`를 갱신한다.
- 요청이 전제한 파일이 저장소에 없으면 임의 생성하지 않는다 — 스코프 결정이므로
  보고 후 사용자 확인을 받는다.

## GitHub 플로우

> `harness.toml`의 `[github] enabled = true` 시 적용. 미사용이면 이 섹션 삭제.

- **브랜치 명명**: `task/{task-id}-{짧은-설명}` (예: `task/1.1-auth-login`)
- **커밋 메시지**: task 브랜치 커밋은 `task {task-id}: {내용}` 형태로 시작 —
  커밋↔Task 추적의 근거 (브랜치명만으로는 squash 머지 후 추적이 끊긴다)
- **Planning**: Week → Milestone은 `gh api repos/{owner}/{repo}/milestones -f title="..."`
  (gh CLI에 milestone 기본 명령 없음). Task → Issue는
  `gh issue create --title "[{task-id}] {내용}" --milestone "..."` — 본문에
  DoD·Acceptance·Depends 기재. 생성된 이슈 번호를 Plans.md GH 컬럼에 `#N`으로 기입
- **Implementation**: Task당 브랜치 생성 → **브랜치에서 해당 Task를 cc:WIP로 마킹**
  → 구현 → reviewer APPROVE 후 PR 오픈. PR 본문에 `Closes #{이슈번호}` 필수
  (누락 시 머지돼도 이슈가 안 닫힌다)
- **Merge 조건**: CI 통과 (`ci` + `plans-guard`) + PR 승인 후 main 머지
- **완료 전환**: 머지 시 `plans-complete.yml`이 해당 Task를 cc:WIP → cc:완료로
  자동 커밋한다. PR 안에서 미리 완료로 바꾸지 말 것 — wip-branch-check가 cc:WIP를
  요구하므로 모순. stale WIP가 main에 남으면 이후 모든 PR이 그 Task의 acceptance를
  재실행하므로 이 자동 전환이 꼭 필요하다
- **Plans.md 충돌 주의**: 여러 task 브랜치가 Plans.md 상태를 동시에 고치면 머지
  충돌이 잦다 — PR 오픈 전 main을 머지해 최신화할 것
- **branch protection**: plans-guard는 PR에만 걸린다. main 직접 push를 막으려면
  Settings → Branches에서 required checks 설정 필수 (`[github] require_ci` 참고)
- **CI 설정**: `.github/workflows/ci.yml` 기술 스택 블록 주석 해제 후 사용

## 구현 규칙 (세분화 게이트)

- **`/harness-work` 실행 전, Plans.md의 대상 cc:TODO Task가 전부
  `agents/task-decomposer.md`의 세분화 기준을 통과했는지 먼저 확인한다.**
  하나라도 미달(DoD·Acceptance 미기재, "전체/모든/및"으로 뭉뚱그린 표현,
  여러 관심사 혼재 등)이면 worker에게 위임하지 않는다 — task-decomposer를
  먼저 실행해 하위 Task로 쪼갠 뒤에만 `/harness-work`를 진행한다.
- 이 게이트는 `.github/workflows/plans-guard.yml`의 `granularity-check` 잡으로도
  기계적으로 강제된다 — PR 단계에서도 동일 기준 미달 Task가 있으면 CI가 막는다.
  세션 중 수동 확인과 CI 게이트를 이중으로 둔 이유: 세션 확인은 worker 호출
  *전에* 낭비를 막고, CI는 그 확인이 생략됐을 때의 최종 방어선이다.
- **worker가 작업 도중 범위가 예상보다 크다는 걸 발견하면**(관련 없는 파일
  3개 이상을 동시에 고쳐야 하거나, 서로 다른 관심사가 뒤섞여 있음을 인지하면)
  즉시 구현을 멈추고 `agents/task-decomposer.md`를 다시 호출한다. 남은 작업을
  `{원본 task-id}.{n}` 형태 하위 Task로 분리하고, 원본 Task는 "분리 완료"로
  마킹한 뒤 하위 Task 단위로 이어서 진행한다 — 같은 에이전트를 재사용해
  계획 단계와 구현 단계 세분화를 하나의 기준으로 유지한다.
- 이 단계는 harness 플러그인이 자동 실행하지 않는다 — `/harness-work` 흐름에서
  Claude가 이 규칙에 따라 직접 수행한다 (`harness.toml [plan] gate_work` 참고).

## 테스트 규칙

- **worker 구현 완료 후, reviewer 검토 전에 `agents/test-agent.md` 절차를 실행한다.**
  Plans.md 해당 Task의 Acceptance 명령 + 프로젝트 테스트 스위트를 돌린다.
- Verdict FAIL이면 reviewer 진입 금지. 실패 내용을 근거로 수정 후 재실행.
- 이 단계는 harness 플러그인이 자동 실행하지 않는다 — `/harness-work` 흐름에서
  Claude가 이 규칙에 따라 직접 수행한다 (`harness.toml [test]` 참고).

## 리뷰 규칙

- **worker 완료 후 PR 오픈 전에 반드시 `/harness-review`를 실행한다.**
- `harness.toml`의 `[review] require_before_pr = true` 설정 시 harness가 자동 강제.
- `/harness-work` 사용 시 step 9(자동 리뷰 스테이지)가 내장 실행됨 — 별도 호출 불필요.
- `/harness-work` 없이 직접 구현한 경우: 커밋 후 PR 오픈 전 `/harness-review` 수동 실행.
- `REQUEST_CHANGES` 상태에서 PR 오픈 금지. 지적 해결 후 재리뷰 통과 필수.

## 개발 일정

- Week 1: [...]
- Week 2: [...]
- Week N: [...]
