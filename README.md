# cc-harness-template

> Claude Code로 개발할 때, 매번 처음부터 설정하지 않아도 되도록 만든 개인 환경 템플릿.

---

## 이 템플릿이 해결하는 문제

Claude Code로 새 프로젝트를 시작할 때마다 반복되는 일이 있다.

- AI가 불필요한 추상화나 과잉 구현을 한다
- 응답이 너무 길어서 읽는 데 시간이 걸린다
- 구현·리뷰·방향 결정을 같은 AI에게 시키면 역할이 뒤섞인다
- 할 일 목록과 실제 구현 상태가 어긋난다

이 템플릿은 그 네 가지를 플러그인 조합으로 해결한다.  
새 프로젝트에 복사하고, 이름만 바꾸면 바로 쓸 수 있다.

---

## 구성 요소 한눈에 보기

이 템플릿은 **4개 Plugin** + **3개 에이전트 규칙** + **프로젝트 설정 파일**로 이루어진다.

### Plugin 4개 — 세션 시작 시 자동으로 켜진다

| Plugin | 한 줄 설명 |
|--------|-----------|
| **claude-code-harness** | Plans.md를 읽어서 할 일을 worker·reviewer·advisor에게 나눠준다 |
| **ponytail** | 코드를 쓰기 전에 "이게 정말 필요한가?"를 7단계로 확인하게 만든다 |
| **caveman** | AI 응답의 군더더기를 제거해 토큰을 약 65% 줄인다 |
| **value-for-fable** | Sonnet 모델에 Fable 5 수준의 진단 규율을 적용한다 |

### 에이전트 4종 — `/harness-work` 실행 시 자동으로 협업한다

```
사용자 → harness → advisor    (방향 결정)
                 → worker     (구현)
                 → test-agent (런타임 검증 — Acceptance + 테스트 스위트)
                 → reviewer   (검토)
```

각 에이전트는 서로 다른 Plugin 조합으로 동작한다.  
worker는 토큰을 아끼면서 구현하고, reviewer와 advisor는 판단 근거를 압축하지 않는다.

| | worker | reviewer | advisor | test-agent |
|--|:------:|:--------:|:-------:|:----------:|
| ponytail (과잉 구현 방지) | ✅ | ✅ | ✅ | — |
| caveman (응답 압축) | lite | — | — | — |
| VFF v2 (진단 구조) | 검증만 | ✅ 전체 | ✅ 전체 | — |

---

## 파일 구조

```
cc-harness-template/
│
├── harness.toml                    # 프로젝트 이름·안전 규칙·review·test 설정
├── CLAUDE.md                       # Claude Code가 항상 읽는 프로젝트 규칙
├── Plans.md                        # 할 일 목록 (cc:TODO / cc:WIP / cc:완료 + Acceptance)
├── BLUEPRINT.md                    # 이 시스템 전체 아키텍처 설명 (읽기용)
│
├── agents/
│   └── test-agent.md               # test-agent 정의 (Acceptance 실행 + 테스트 스위트)
│
├── .github/                        # GitHub 연동 시 사용 (harness.toml enabled = true)
│   ├── workflows/
│   │   ├── ci.yml                  # 빌드·테스트 CI (스택 블록 주석 해제 후 사용)
│   │   └── plans-guard.yml         # WIP 브랜치 확인 + Acceptance Oracle
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│
├── .claude/
│   ├── settings.local.json         # 이 프로젝트 전용 권한 설정
│   └── agent-memory/
│       ├── claude-code-harness-worker/MEMORY.md    # worker 행동 규칙
│       ├── claude-code-harness-reviewer/MEMORY.md  # reviewer 행동 규칙
│       └── claude-code-harness-advisor/MEMORY.md   # advisor 행동 규칙
│
└── docs/
    ├── setup-guide.md              # 상세 설치 가이드
    ├── github-integration.md       # GitHub 연동 상세 가이드
    └── global-settings-reference.md  # ~/.claude/settings.json 레퍼런스
```

> **MEMORY.md가 하는 일**: harness가 에이전트를 실행할 때 이 파일을 읽어서  
> "이 에이전트는 caveman lite로 응답해라", "VFF v2 전체를 적용해라"처럼 행동 규칙을 주입한다.  
> `.claude/agent-memory/` 경로가 고정이므로 위치를 바꾸면 안 된다.

---

## 설치

> **처음 한 번만 한다.** 다음 프로젝트부터는 [새 프로젝트에 적용](#새-프로젝트에-적용) 섹션만 보면 된다.

### 사전 조건

- [Claude Code CLI](https://claude.ai/code) 설치됨
- Node.js 18 이상 (`node --version`으로 확인)

### Step 1 — `~/.claude/settings.json` 수정

이 파일이 없으면 새로 만든다. 있으면 기존 내용에 병합한다.

```json
{
  "enabledPlugins": {
    "claude-code-harness@claude-code-harness-marketplace": true,
    "ponytail@ponytail": true,
    "caveman@caveman": true,
    "value-for-fable@itsinseong": true
  },
  "extraKnownMarketplaces": {
    "claude-code-harness-marketplace": {
      "source": {
        "source": "github",
        "repo": "Chachamaru127/claude-code-harness"
      }
    },
    "ponytail": {
      "source": {
        "source": "github",
        "repo": "DietrichGebert/ponytail"
      }
    },
    "caveman": {
      "source": {
        "source": "github",
        "repo": "JuliusBrussee/caveman"
      }
    },
    "itsinseong": {
      "source": {
        "source": "git",
        "url": "https://github.com/itsinseong/value-for-fable.git"
      }
    }
  },
  "tui": "fullscreen",
  "theme": "dark"
}
```

### Step 2 — Plugin 설치

```bash
claude plugin install claude-code-harness@claude-code-harness-marketplace
claude plugin install ponytail@ponytail
claude plugin install caveman@caveman
claude plugin install value-for-fable@itsinseong
```

각 명령은 30초~1분 소요. 에러 없이 끝나면 된다.

### Step 3 — 설치 확인

```bash
harness doctor
```

모든 항목에 체크가 붙으면 완료.

---

## 새 프로젝트에 적용

### Step 1 — 템플릿 파일 복사

```bash
# 내 프로젝트 디렉토리로 이동
cd /path/to/my-new-project

# 템플릿 클론 (임시)
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl

# 파일 복사
cp /tmp/harness-tpl/harness.toml .
cp /tmp/harness-tpl/CLAUDE.md .
cp /tmp/harness-tpl/Plans.md .
cp /tmp/harness-tpl/BLUEPRINT.md .

mkdir -p .claude/agent-memory/claude-code-harness-worker
mkdir -p .claude/agent-memory/claude-code-harness-reviewer
mkdir -p .claude/agent-memory/claude-code-harness-advisor

cp /tmp/harness-tpl/.claude/agent-memory/claude-code-harness-worker/MEMORY.md \
   .claude/agent-memory/claude-code-harness-worker/
cp /tmp/harness-tpl/.claude/agent-memory/claude-code-harness-reviewer/MEMORY.md \
   .claude/agent-memory/claude-code-harness-reviewer/
cp /tmp/harness-tpl/.claude/agent-memory/claude-code-harness-advisor/MEMORY.md \
   .claude/agent-memory/claude-code-harness-advisor/
cp /tmp/harness-tpl/.claude/settings.local.json .claude/
```

### Step 2 — 커스터마이징 체크리스트

복사 후 반드시 아래 항목을 채워야 한다. 비워두면 AI가 엉뚱한 컨텍스트로 동작한다.

**`harness.toml`**
```toml
[project]
name = "my-actual-project"   # ← 이 프로젝트 이름으로 변경
description = "한 줄 설명"    # ← 변경
```

**`CLAUDE.md`**  
`[PROJECT_NAME]`, 기술 스택, 디렉토리 구조, 코딩 규칙 섹션을 실제 프로젝트에 맞게 채운다.

**`Plans.md`**  
Week 구조와 Task를 정의한다.  
DoD는 **검증 가능한 형태**로, Acceptance는 **CI가 직접 실행하는 명령어**로 쓴다.

```markdown
# 좋은 DoD / Acceptance 예시
DoD: `npm run build` 에러 0, dist/index.js 존재
Acceptance: npm run build 2>&1 | grep -v error   ← CI가 실행, 실패 시 PR 차단

# 나쁜 예시
DoD: 코드가 잘 작성됨
Acceptance: -  (기계 검증 없음)
```

**`.claude/agent-memory/*/MEMORY.md`**  
세 파일 모두 아래 섹션을 찾아서 채운다:

```markdown
## Project Context

프로젝트: [실제 프로젝트 이름]
목표: [핵심 목표 한 줄]
```

### Step 3 — harness 동기화

```bash
harness sync    # harness.toml → .claude-plugin/ 파일 생성
harness doctor  # 전체 통과 확인
```

### Step 4 — GitHub 연동 (선택)

GitHub Issues·Milestone·CI·PR을 harness와 연동하려면:

```toml
# harness.toml
[github]
enabled = true
```

```bash
gh auth login   # GitHub CLI 로그인
harness sync    # 연동 활성화
```

`.github/workflows/ci.yml`에서 기술 스택 블록 주석 해제 후 branch protection 설정.  
→ 상세: [docs/github-integration.md](./docs/github-integration.md)

---

## 일상 워크플로우

```bash
# 1. Claude Code 열기
claude

# 2. 할 일 추가 (Plans.md에 Task 작성)
/harness-plan

# 3. 실행 (worker → reviewer → advisor 자동 순환)
/harness-work

# 4. 진행 상황 확인
/harness-progress

# 5. Plans.md ↔ 구현 동기화 확인
/harness-sync
```

### harness-work 내부 흐름

`/harness-work`를 치면 harness가 자동으로:

1. Plans.md에서 `cc:TODO` 상태 Task를 선택
2. **advisor**에게 방향 물어봄 (VFF v2 전체 적용 — 핵심 변수 먼저, 일반론 금지)
3. **worker**에게 구현 위임 (ponytail 7단계 + VFF 검증 의무)
4. **test-agent**가 런타임 검증 — Acceptance 명령 + 프로젝트 테스트 스위트 실행  
   FAIL 시 worker에 재위임, PASS 시에만 다음 단계 진행
5. **reviewer**에게 검토 요청 (VFF v2 전체 — 판단 근거 명확하게)
6. 완료 시 Plans.md 마커를 `cc:WIP` → `cc:완료`로 자동 업데이트

---

## 명령어 치트시트

| 명령어 | 동작 |
|--------|------|
| `harness doctor` | 설치 상태 전체 점검 |
| `harness sync` | `harness.toml` 변경 후 적용 |
| `/harness-plan` | Plans.md Task 추가·관리 |
| `/harness-work` | Task 실행 (worker 팀 가동) |
| `/harness-review` | 현재 코드·계획 리뷰 |
| `/harness-progress` | 진행 현황 대시보드 |
| `/harness-sync` | Plans.md ↔ 구현 상태 동기화 확인 |
| `/caveman lite` | 응답 압축을 약하게 (조사·문장 구조 유지) |
| `/caveman full` | 응답 압축 기본값 (관사·filler 제거) |
| `/caveman ultra` | 최대 압축 |
| `/ponytail lite\|full\|ultra` | lazy mode 강도 조절 |
| `/itsvff` | VFF 세션 모드 수동 활성화 |
| `/ponytail-review` | 현재 diff 과잉 구현 리뷰 |

### Plans.md Task 마커

| 마커 | 의미 |
|------|------|
| `cc:TODO` | 미시작. harness가 선택 대상으로 봄 |
| `cc:WIP` | 진행 중. harness가 자동으로 설정 |
| `cc:완료` | 완료. harness가 자동으로 설정 |

---

## 문제 해결

### `harness: command not found`

```bash
# harness CLI 경로 확인
which harness

# 없으면 plugin 재설치
claude plugin uninstall claude-code-harness@claude-code-harness-marketplace
claude plugin install claude-code-harness@claude-code-harness-marketplace
```

### `harness doctor`에서 특정 항목 실패

```bash
harness sync
harness doctor
```

sync 후 재확인. 여전히 실패하면 해당 plugin을 재설치.

### worker가 caveman full로 응답할 때 (lite여야 함)

`.claude/agent-memory/claude-code-harness-worker/MEMORY.md`에  
`### caveman: lite 모드` 섹션이 있는지 확인.  
Claude Code를 재시작하면 MEMORY.md를 다시 로드한다.

### Plans.md Task가 선택되지 않을 때

Task 상태가 `cc:TODO`인지 확인. `cc:WIP`는 이미 진행 중으로 간주되어 건너뜀.

---

## 심화 문서

| 문서 | 내용 |
|------|------|
| [BLUEPRINT.md](./BLUEPRINT.md) | Plugin 간 협력 관계, 세션 타임라인, 에이전트 매트릭스 전체 설명 |
| [docs/setup-guide.md](./docs/setup-guide.md) | 설치 상세 절차, OS별 경로, 재설치 방법 |
| [docs/github-integration.md](./docs/github-integration.md) | GitHub Issues·CI·Acceptance Oracle 연동 상세 가이드 |
| [docs/global-settings-reference.md](./docs/global-settings-reference.md) | `~/.claude/settings.json` 전체 항목 설명 |

---

## Plugin 버전 (이 템플릿 작성 기준)

| Plugin | 버전 | GitHub |
|--------|------|--------|
| claude-code-harness | 4.16.3 | [Chachamaru127/claude-code-harness](https://github.com/Chachamaru127/claude-code-harness) |
| ponytail | 4.8.3 | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| caveman | 25d22f8 | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| value-for-fable | 1.0.1 | [itsinseong/value-for-fable](https://github.com/itsinseong/value-for-fable) |
