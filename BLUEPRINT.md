# BLUEPRINT.md — Claude Code Harness 시스템 구조

> 이 문서는 설치된 harness 시스템이 어떻게 동작하는지 한눈에 파악하기 위한 설계도다.
> 코드가 아니라 "각 레이어가 무슨 역할을 하고, 언제 발동되며, 어떻게 맞물리는가"를 설명한다.

---

## 전체 구조 한 줄 요약

```
사용자 요청
  → [Plugin Layer] 세션 시작·프롬프트 제출 시 자동 주입
  → [Harness Layer] 요청을 분석해 적절한 Agent에게 위임
  → [Agent Layer] Worker / Reviewer / Advisor 각자의 규칙으로 실행
  → 결과 반환
```

---

## 1. Plugin Layer (전역 — user scope)

세션이 시작되거나 프롬프트가 제출될 때 자동으로 동작하는 네 개의 플러그인.
Claude Code가 관리하며, 이 프로젝트에만 한정되지 않고 모든 세션에 적용된다.

### 1-1. claude-code-harness v4 (핵심 엔진)

Harness 전체를 구동하는 엔진. `harness` 명령어로 직접 호출하거나,
스킬(`/harness-work`, `/harness-plan` 등)을 통해 간접 호출된다.
Plans.md의 Task를 읽어 worker·reviewer·advisor에게 배분하는 오케스트레이터 역할.

**주요 명령어**
```
harness init      → 프로젝트 초기화 (harness.toml 생성)
harness sync      → harness.toml → .claude-plugin/ 파일 동기화
harness doctor    → 설치 상태 전체 점검
```

**설치**
```bash
# ~/.claude/settings.json의 extraKnownMarketplaces에 추가 후:
claude plugin install claude-code-harness@claude-code-harness-marketplace
```

---

### 1-2. ponytail (코드 효율 강제)

"게으른 시니어 개발자" 모드. 코드를 작성하기 전에 7단계 의사결정 사다리를 실행해
불필요한 코드 작성을 막는다.

**발동 시점**

| Hook | 타이밍 | 동작 |
|------|--------|------|
| `SessionStart` | 세션 시작 시 | lazy senior dev 시스템 프롬프트 주입 |
| `SubagentStart` | 서브에이전트 시작 시 | worker 등 서브에이전트에도 동일 규칙 주입 |
| `UserPromptSubmit` | 매 프롬프트 제출 시 | 현재 모드 상태 추적 |

> 핵심: `SubagentStart` 훅 덕분에 harness가 worker를 spawning할 때 **자동으로** ponytail이 함께 적용된다.

**7단계 의사결정 사다리**
```
1. 정말 필요한가? (YAGNI)
2. 이미 코드베이스에 있는가? (재사용)
3. 표준 라이브러리로 가능한가?
4. 네이티브 플랫폼 기능인가?
5. 설치된 의존성으로 가능한가?
6. 한 줄로 가능한가?
7. 그제야: 최소 필수 코드만 작성
```

**설치**
```bash
claude plugin install ponytail@ponytail
```

---

### 1-3. caveman (출력 토큰 압축)

응답을 "스마트 원시인"처럼 압축해 출력 토큰을 평균 65% 줄인다.
기술적 정확성은 그대로 유지.

**발동 시점**

| Hook | 타이밍 | 동작 |
|------|--------|------|
| `SessionStart` | 세션 시작 시 | caveman 모드 주입 (기본: full) |
| `UserPromptSubmit` | 매 프롬프트 제출 시 | 모드 상태 추적 |

**압축 강도**
```
lite   → filler/hedging만 제거. 문장 구조·조사 유지.
full   → 관사 생략, 단편 문장 허용, 짧은 동의어. (기본값)
ultra  → 극단적 압축. 단어도 약어화.
```

> worker 에이전트는 `lite`로 고정된다 (2절 참조).

**설치**
```bash
claude plugin install caveman@caveman
```

---

### 1-4. value-for-fable (Fable 5 품질 구조)

Sonnet 모델에 Fable 5의 운영 규율을 적용해 Opus 수준 품질을
Sonnet 비용(약 70% 절감)으로 끌어낸다. 압축이 아니라 **진단 구조**가 핵심.

**컴포넌트 구성**

| 컴포넌트 | 활성화 방식 | 역할 |
|---------|-----------|------|
| Skill (`/itsvff`) | "VFF", "패블 모드" 수동 트리거 | 현재 세션에 즉시 적용 |
| Output Style (vff-v2) | reviewer/advisor MEMORY.md 지시 | 응답 구조 상시 적용 |
| Agent (itsvff) | 복잡한 과제 자동 위임 | 별도 컨텍스트에서 처리 |
| Hook (reminder.sh) | 컨텍스트 400KB 초과 시 자동 | 장시간 세션 드리프트 방지 |

**VFF v2 핵심 원칙**
```
- 첫 문장 = 결론
- 단서 우선 가설 (모든 단서를 설명하는 원인 먼저)
- 측정 먼저 좁히기 (처방 전에 가장 싼 확인 수단 제시)
- 확신도 표시 (직접 보지 않은 것은 단정하지 않는다)
- 충실함 > 압축
```

**설치**
```bash
# ~/.claude/settings.json의 extraKnownMarketplaces에 git URL 추가 후:
claude plugin install value-for-fable@itsinseong
```

---

## 2. Agent Layer (per-agent 규칙)

harness가 요청을 처리할 때 spawning하는 세 종류의 에이전트.
각각 다른 Plugin 조합을 적용한다.

```
.claude/agent-memory/
├── claude-code-harness-worker/MEMORY.md    ← worker 전용 규칙
├── claude-code-harness-reviewer/MEMORY.md  ← reviewer 전용 규칙
└── claude-code-harness-advisor/MEMORY.md   ← advisor 전용 규칙
```

### Plugin 적용 매트릭스

| | worker | reviewer | advisor |
|--|:------:|:--------:|:-------:|
| **ponytail** (코드 효율) | 전체 | 전체 | 전체 |
| **caveman** (토큰 압축) | **lite** | OFF | OFF |
| **VFF v2** (진단 구조) | 검증·코드 규율만 | **전체** | **전체** |
| **VFF Hook** (드리프트 방지) | 전역 발동 | 전역 발동 | 전역 발동 |

### worker
구현 담당. Plans.md의 Task를 실제로 코드로 만드는 역할.
- **caveman lite**: filler 제거, 문장 구조는 유지 → 간결하되 읽을 수 있는 응답
- **ponytail 전체**: 코드 작성 전 7단계 사다리 → MVP 범위 외 구현 금지
- **VFF 검증·코드 규율만**: 완료 선언 전 검증 의무 + 요청 범위 외 수정 금지

### reviewer
완료된 구현을 검토하는 역할.
- **caveman OFF**: 판단 근거와 리뷰 내용은 압축하지 않는다
- **ponytail 전체**: 과도한 추상화·오버엔지니어링 지적 기준으로 활용
- **VFF v2 전체**: 단서 우선 진단, 확신도 표시, 핵심 변수 1~2개로 추천

### advisor
방침과 설계 방향을 결정하는 역할.
- **caveman OFF**: 설계 근거는 압축 없이 명확하게
- **ponytail 전체**: YAGNI 원칙 우선 적용
- **VFF v2 전체**: 의사결정 조언 시 핵심 변수 먼저, 일반론 나열 금지

---

## 3. Harness Layer (프로젝트 설정)

harness 자체의 동작을 정의하는 파일들.

```
[project-root]/
├── harness.toml              ← 프로젝트명·버전·안전 규칙 정의
├── .claude/
│   ├── settings.local.json   ← 프로젝트 스코프 권한 설정
│   └── agent-memory/         ← 각 Agent MEMORY.md
├── CLAUDE.md                 ← 프로젝트 전역 규칙 (기술 스택, 응답 포맷 등)
└── Plans.md                  ← Task 목록 (cc:TODO / cc:WIP / cc:완료 마커)
```

**harness.toml 주요 설정**
```toml
[project]
name = "my-project"

[safety.permissions]
deny = ["Bash(sudo:*)"]
ask  = ["Bash(rm -r:*)", "Bash(git push --force:*)"]
```

---

## 3.5 GitHub 통합 레이어 (선택)

`harness.toml`의 `[github] enabled = true` 설정 시 활성화.

> **주의**: `[github]`·`[review]`·`[test]` 섹션은 harness sync가 파싱하지 않는
> 프로젝트 규약이다 (플러그인 지원 섹션: project/agent/env/safety/tdd).
> 실제 동작은 CLAUDE.md의 지시에 따라 Claude가 세션에서 gh CLI로 직접 수행한다.
> CI 게이트(ci.yml, plans-guard.yml)만 GitHub Actions가 기계적으로 강제한다.

### 활성화 전제조건
```bash
gh auth login          # GitHub CLI 로그인
gh repo view           # 현재 디렉토리가 GitHub 원격 repo에 연결됐는지 확인
harness sync           # toml → plugin 파일 동기화
```

### Planning 단계 (`/harness-plan`)

| 액션 | Plans.md 입력 | GitHub 결과 |
|------|-------------|-------------|
| Week 항목 | `## Week 1 — [주제]` | Milestone `Week 1` 생성 |
| Task 행 | `| 1.1 | 내용 | ...` | Issue `[1.1] 내용` 생성, Milestone 연결 |
| Issue 번호 기록 | — | Plans.md `GH` 컬럼에 `#N` 자동 기입 |

### Implementation 단계 (`/harness-work`)

```
Task 선택 (cc:TODO)
  → git checkout -b task/{task-id}-{설명}
  → worker 구현
  → reviewer 검토
  → gh pr create --title "[{task-id}] ..." --body "Closes #{issue}"
  → CI 통과 + 승인 후 main 머지
  → Plans.md cc:WIP → cc:완료 자동 업데이트
```

### CI 게이트

| Workflow | 트리거 | 목적 |
|----------|--------|------|
| `ci.yml` | push/PR → main | 기술 스택별 빌드·테스트 |
| `plans-guard.yml` | PR → main | WIP Task ↔ 브랜치 일관성 검증 + Acceptance Oracle 실행 |

### Acceptance Oracle

Plans.md 각 Task의 `Acceptance` 컬럼에 기계 검증 명령을 기입한다.
PR 오픈 시 `plans-guard.yml`이 WIP Task의 acceptance 명령을 실행하고, 실패 시 PR을 차단한다.

```markdown
| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
| 1.1  | 로그인 구현 | 200 응답 | pytest tests/test_auth.py -k login | - | cc:WIP | #5 |
| 2.0  | DB 마이그레이션 | 스키마 적용 | python manage.py showmigrations \| grep '\[X\]' | 1.1 | cc:WIP | #8 |
```

- `-` 이면 acceptance 검증 skip (기계 검증 불가 항목)
- 명령이 0 외 종료 코드를 반환하면 PR 차단
- 스택 설정(npm ci, pip install 등)은 `plans-guard.yml` 상단 주석 해제

### Branch Protection 권장 설정

```
GitHub → Settings → Branches → main:
  ✓ Require status checks to pass: ci, plans-guard/WIP↔Branch, plans-guard/Acceptance Oracle
  ✓ Require pull request before merging
  ✓ Dismiss stale pull request approvals
```

> 상세 설정 가이드: `docs/github-integration.md`

---

## 4. 세션 타임라인 — 실제 실행 흐름

### 세션 시작 시
```
1. ponytail SessionStart 훅 → lazy senior dev 시스템 프롬프트 주입
2. caveman SessionStart 훅  → caveman 모드 주입 (기본 full)
   ※ worker spawning 시: worker MEMORY.md의 "lite" 지시로 전환
```

### 매 프롬프트 제출 시
```
3. ponytail UserPromptSubmit 훅  → 현재 모드 상태 추적
4. caveman UserPromptSubmit 훅   → 현재 모드 상태 추적
5. VFF UserPromptSubmit 훅       → 컨텍스트 400KB 초과 + VFF 활성 상태면
                                    VFF 리마인더를 컨텍스트에 주입
```

### harness-work 실행 시 (`/harness-work`)
```
6. harness가 Plans.md에서 cc:TODO Task 선택
7. advisor에게 방침 요청 (caveman OFF + VFF v2)
8. worker에게 구현 위임 (caveman lite + ponytail + VFF 검증)
   └─ SubagentStart 훅 → ponytail이 worker에 자동 주입
9. test-agent 검증 (Acceptance 명령 + 프로젝트 테스트 스위트) — FAIL 시 worker에 재위임
10. reviewer에게 검토 요청 (caveman OFF + VFF v2)
11. 결과를 Plans.md에 반영 (cc:WIP → cc:완료)
```

---

## 5. 사용 가능한 스킬 명령어

| 명령어 | 역할 |
|--------|------|
| `/harness-plan` | Plans.md Task 추가·관리 |
| `/harness-work` | Plans.md Task 실행 (worker 팀 가동) |
| `/harness-review` | 코드·계획 리뷰 |
| `/harness-sync` | Plans.md ↔ 구현 상태 동기화 확인 |
| `/harness-progress` | 진행 현황 대시보드 |
| `/ponytail [lite\|full\|ultra]` | ponytail 강도 수동 조절 |
| `/caveman [lite\|full\|ultra]` | caveman 강도 수동 조절 |
| `/itsvff` | VFF 세션 모드 수동 활성화 |
| `/ponytail-review` | 현재 diff ponytail 기준 리뷰 |

---

## 6. Plugin 간 협력 관계 요약

```
ponytail ──────────────────────────────────────────▶ 모든 Agent
  코드를 쓰기 전에 "정말 필요한가?"를 강제

caveman ───────────────────────────────────────────▶ worker(lite), reviewer/advisor(OFF)
  worker: 간결한 진행 응답 / reviewer·advisor: 판단 근거 명확히

VFF v2 ────────────────────────────────────────────▶ reviewer/advisor(전체), worker(검증만)
  진단 구조 + 확신도 + 결론 첫 문장

VFF Hook ──────────────────────────────────────────▶ 전체 (400KB+ 세션)
  장시간 세션에서 VFF 원칙이 희미해지는 것을 자동으로 방지

harness ───────────────────────────────────────────▶ 전체 조율
  Plans.md 기반으로 위 세 Agent를 오케스트레이션
```
