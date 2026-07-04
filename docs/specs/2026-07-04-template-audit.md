# 템플릿 감사 보고서 — 빈틈 분석 + 개선 계획

작성일: 2026-07-04
범위: cc-harness-template 전체 (CI 워크플로·CLAUDE.md 규약·에이전트 정의·온보딩 절차·상태 문서)
방법: 전 파일 정독 + plans-guard/plans-complete 파싱 로직 수기 검증
후속: Plans.md Week 3 Task로 반영 (본 문서 하단 매핑표)

---

## 요약

CI 게이트 자체(파싱·시나리오 4종)는 Task 2.7에서 검증 완료 — 빈틈은 게이트 *주변*에 있다.

1. 권장 설정끼리 서로를 죽인다 (H1: branch protection ↔ plans-complete)
2. 게이트가 안 보는 경로가 열려 있다 (H2: 비-task 브랜치 우회, H3: Depends 미강제)
3. GitHub 미사용 시 기계 강제가 통째로 사라진다 (H4)
4. 온보딩 절차가 깨진 프로젝트를 찍어낸다 (H5)

---

## 높음 (H) — 설계 모순·우회 경로

### H1. branch protection ↔ plans-complete.yml 정면 충돌

- CLAUDE.md GitHub 플로우는 main 직접 push 차단(required checks + PR 필수)을 지시.
- 그런데 `plans-complete.yml`(56행)은 github-actions bot이 main에 **직접 push**한다.
- "Require a pull request before merging" 활성화 → bot push 거부 → 워크플로 머지 후
  조용히 실패 → stale WIP 잔류 → **이 워크플로가 막으려던 문제가 그대로 재발**.
- Task 2.7 E2E는 protection 없는 테스트 repo에서 수행돼 미검출.
- 개선 방향: ruleset bypass 등록 / fine-grained PAT / flip을 자동 PR로 올리는 방식 중 택1.
  검증은 protection 켠 테스트 repo에서 재실행.

### H2. 비-task 브랜치 PR = Plans.md 게이트 전면 우회

- `plans-guard.yml` wip-branch-check(30행): `task/*` 아니면 skip.
- acceptance·granularity는 cc:WIP 행만 검사.
- 따라서 `docs/x` 등 임의 브랜치에서 아무 Task나 직접 `cc:완료`로 flip, 행 삭제·수정
  가능 — 검사 0개 통과.
- task 브랜치도 자기 행 외 다른 행 수정을 아무도 안 본다 (Plans.md diff 검사 없음).
- 개선 방향: plans-guard에 diff 기반 잡 추가 — Status 컬럼 변경은 본인 task 행 +
  cc:TODO→cc:WIP 방향만 허용, cc:완료 전환은 plans-complete bot 커밋만 허용.

### H3. Depends 컬럼이 어디서도 강제되지 않음

- granularity-check(179행)는 "비어있지 않음"만 확인.
- 선행 Task cc:완료 여부를 세션 규칙도 CI도 검사 안 함 — 3.1이 TODO인데 3.2 WIP 가능.
- 결과: CLAUDE.md의 "UI Task는 DESIGN.md Task를 Depends로 게이트" 규약이 이빨 없음.
- 개선 방향: plans-guard에 depends-check 잡 — WIP 행의 Depends가 가리키는 Task가
  전부 cc:완료인지 확인, 아니면 FAIL.

### H4. GitHub 미사용 모드 = 기계 강제 0

- `[github] enabled = false`(기본값)면 CI 부재 → 세분화 게이트·test-agent·리뷰 필수가
  전부 "Claude가 CLAUDE.md 읽고 자발 수행"에 의존. 훅 기반 강제 전무.
- 자기 규율 실패의 실증이 repo 안에 있었음: HANDOFF.md가 "Week 2 미커밋·커밋 금지"
  상태로 stale — 실제로는 2.6·2.7 커밋+push 완료 (2026-07-04 감사에서 발견, 즉시 교정).
- 개선 방향(후보): PreToolUse/Stop 훅으로 최소 강제(예: Plans.md 수정 시 상태 문서
  갱신 리마인드, `gh pr create` 전 리뷰 여부 확인). 과강제는 YAGNI — 훅 1~2개부터.

### H5. README "새 프로젝트에 적용" 절차가 깨진 프로젝트 생성

- cp 목록 누락: `plans-complete.yml`(stale WIP 방지 핵심), `ci.yml`, `.harness/` 골격
  7종, PR/Issue 템플릿.
- plans-guard만 복사 + CLAUDE.md 머지 조건("ci + plans-guard")대로 required checks
  설정 시 `ci` 체크가 존재하지 않아 **영구 머지 불가**.
- 복사 대상 Plans.md·BLUEPRINT에 이 템플릿 자신의 dogfood 이력 포함
  (`../routine-saas` 경로 등) — 새 프로젝트가 남의 완료 Task를 물려받음.
- LESSONS 결함 1(초기화 수동)과 동근원 — clean 골격 분리 + init 스크립트로 함께 해결.

## 중간 (M) — 침식·드리프트

### M1. Plans.md 파서 3중 복제 + 스키마 변경 시 조용한 무력화

- 동일 파싱 로직이 plans-guard 2개 잡 + plans-complete에 복사됨.
- 컬럼 하나 제거(GH 등) 시 `n < 8` 가드가 전 행을 말없이 skip → CI 초록불.
- 헤더 검증 없음. "게이트가 도는 것"과 "아무것도 안 보는 것"이 구분 불가.
- 개선 방향: 헤더 행 검증(7컬럼 + 컬럼명 일치) 선행 후 파싱, 불일치 시 명시적 FAIL.
  파서 공용 스크립트(scripts/) 추출은 워크플로 3곳 수정과 함께 판단.

### M2. 템플릿 스스로 나쁜 Acceptance 패턴을 예시로 가르침

- Task 0.4 `... || echo skip`: 항상 exit 0 — oracle 무력화 패턴을 견본으로 제공.
- Week 2 행들의 `../routine-saas/` 경로: CI checkout 밖 — 실행 불가능한 acceptance.
- 개선 방향: 해당 행 acceptance `-` 처리 + Plans.md 주석에 anti-pattern 경고 추가
  (`|| echo skip` 금지, repo 밖 경로 금지).

### M3. 완료 전환 규칙 서술이 문서 3곳에서 모순

- CLAUDE.md: "PR 안에서 완료로 바꾸지 말 것 (plans-complete가 자동 전환)".
- README(317행 부근)·BLUEPRINT(324행 부근): "완료 시 cc:WIP→완료 자동 업데이트"
  (세션이 직접 flip하는 서술) — GitHub 모드에서 따르면 wip-branch-check와 충돌.
- 개선 방향: CLAUDE.md 기준으로 README·BLUEPRINT 서술 통일. 모드별(로컬/GitHub)
  전환 주체를 한 곳에서 표로 정리하고 나머지는 참조만.

### M4. harness.toml 미파싱 섹션 = 죽은 설정 + 이중 SSOT

- `[github]`·`[review]`·`[test]`·`[plan]`은 harness sync가 파싱 안 함 (주석에 자인).
- "SSOT"라 주장하나 실제 읽히는 건 CLAUDE.md — 동기화는 수동 규약, 드리프트 감지 없음.
- `max_iterations`·`timeout_seconds` 등은 어디서도 사용 안 됨.
- 개선 방향: 미사용 키 삭제, 섹션 주석에 "CLAUDE.md가 실행 SSOT, 여긴 요약 인덱스"로
  역할 반전 명시. 또는 섹션 자체를 CLAUDE.md로 흡수하고 toml에서 제거.

### M5. agents/*.md는 호출 가능한 에이전트가 아님

- Claude Code 서브에이전트 경로는 `.claude/agents/`, 필드는 `tools` —
  `agents/` + `role`/`allowed-tools` frontmatter는 어떤 런타임도 읽지 않음.
- "task-decomposer를 실행한다"의 실체 = 오케스트레이터 Claude의 롤플레이.
  allowed-tools 제한 미강제. BLUEPRINT "직접 호출" 서술은 메커니즘 부재를 은폐.
- 개선 방향: 둘 중 택1 — ① `.claude/agents/`로 이전해 실제 서브에이전트화,
  ② 현행 유지하되 BLUEPRINT·README에 "절차 문서(수행 주체: 세션 Claude)"로 명시.

### M6. required check 이름이 깨지기 쉬움

- placeholder job명(`CI (스택 미설정 — ...)`)을 required check로 등록 후 스택 블록
  활성화로 job명이 바뀌면 → 존재하지 않는 체크 대기(영구 블록) 또는 무방비.
- 개선 방향: ci.yml에 이름 고정 요약 잡(`ci-ok` needs: [check, test]) 두고
  required check는 그 하나만 등록 — 스택 전환에도 이름 불변.

### M7. escaped pipe가 Acceptance 컬럼에서만 생존

- DoD에 `grep 'a\|b'` 류 사용 시 필드 수 증가 → acceptance 재조립에 DoD 조각 혼입
  → eval 오염 → 무고한 PR 차단. (오른쪽 카운팅으로 Status는 생존)
- 개선 방향: M1 헤더 검증과 묶어 처리하거나, Plans.md 주석에 "escaped pipe는
  Acceptance 컬럼만 허용" 규약 명시(저비용안).

### M8. 플러그인 공급망 무방비

- 서드파티 repo 4개가 매 세션 시스템 프롬프트 주입. 버전 고정 수단 없음
  (README 표는 기록일 뿐, install은 latest). 마켓플레이스 업데이트 = 전 프로젝트
  행동 변경.
- 개선 방향: 저비용안 — README에 "검증된 커밋 SHA" 기록 + 업데이트 전 changelog
  확인 절차 한 단락. 강제 핀 기능은 플러그인 시스템 지원 범위 밖 (YAGNI 보류).

## 낮음 (L) — 백로그

- L1. granularity `vague_re`: "그리고" 오탐 / "와·과"·쉼표 나열 미탐. 내용 컬럼만 검사.
- L2. test-agent 스택 감지: `grep -q '"test"' package.json`이 `"pretest"`에도 매치.
  모노레포 미고려.
- L3. CONTEXT_INDEX.md가 이 repo에 없는 docs/PRD.md·UserFlow.md·Architecture.md 인덱싱.
- L4. 권한 패턴 `Bash(rm -r:*)`가 `rm -fr`·`rm -R` 미포착 (prefix 매치 특성).
- L5. grill-me 산출 경로 인자 부재(LESSONS 기재) + 1문1답 방식 headless 비호환.

---

## 개선 계획 — Week 3 Task 매핑

우선순위: H1·H5(권장 설정이 스스로를 깨는 문제) → H2·H3(우회 차단) → M(침식 방지).
H4 훅 강제는 범위 커서 Week 3에서 최소안만 (선행: H1~H3 완료 후 판단).
L 항목은 Task화하지 않음 — 발생 시 처리.

| Task | 대상 빈틈 | 내용 |
|------|----------|------|
| 3.1 | H1 | plans-complete branch protection 호환 (bypass/PR 방식 결정+구현) |
| 3.2 | H5·LESSONS결함1 | clean 골격 세트 분리 (templates/skeleton/) |
| 3.3 | H5 | init.sh 초기화 스크립트 (cp 목록 완전판, README 갱신) |
| 3.4 | H2 | plans-guard에 Plans.md diff 보호 잡 추가 |
| 3.5 | H3 | plans-guard에 depends-check 잡 추가 |
| 3.6 | M1·M7 | Plans.md 헤더 검증 선행 파싱 (3 워크플로) |
| 3.7 | M3 | 완료 전환 서술 통일 (README·BLUEPRINT → CLAUDE.md 기준) |
| 3.8 | M4 | harness.toml 죽은 설정 정리 + 역할 재정의 |
| 3.9 | M2 | Plans.md anti-pattern 예시 교정 + 주석 경고 |
| 3.10 | M5 | agents/*.md 수행 주체 명시 (문서 정정, 이전 여부 결정 포함) |
| 3.11 | M6 | ci.yml 이름 고정 요약 잡 (`ci-ok`) 도입 |
| 3.12 | M8 | 플러그인 SHA 기록 + 업데이트 절차 문서화 |

상세 DoD·Acceptance·Depends는 Plans.md Week 3 표가 SSOT.
