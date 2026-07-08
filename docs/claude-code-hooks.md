# Claude Code Hooks 설정 가이드

이 템플릿엔 현재 hooks가 설정돼 있지 않다. `.claude/settings.local.json.example`은
`permissions`(deny/ask)만 담고 있고 `hooks` 키는 없다. 이 문서는 훅을 추가하려는
사람을 위한 가이드다 — 여기 나온 예시는 전부 "추가 권장"이지 이 저장소에
이미 켜져 있는 것이 아니다.

---

## Hooks가 하는 일

Claude Code hooks는 특정 이벤트(도구 호출 전/후, 세션 종료 등)에 shell command를
자동 실행한다. `.claude/settings.json` 또는 `.claude/settings.local.json`의
`hooks` 키에 등록한다.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "npx prettier --write \"$CLAUDE_TOOL_INPUT_FILE_PATH\"" }]
      }
    ]
  }
}
```

주요 이벤트: `PreToolUse`(도구 실행 전, 차단 가능) · `PostToolUse`(실행 후) ·
`Stop`(세션 응답 종료 시) · `SessionStart`(세션 시작 시). 정확한 스키마는
Claude Code 공식 문서(`/help` 또는 설정 문서)를 기준으로 삼는다 — 버전마다
달라질 수 있어 이 문서는 예시 골격만 제공한다.

---

## `harness.toml [safety.permissions]`와의 역할 분담

이 템플릿은 위험한 명령 확인을 이미 `harness.toml`의 `[safety.permissions]`
(`deny`/`ask` 목록)로 처리한다.

```toml
[safety.permissions]
deny = ["Bash(sudo:*)"]
ask = ["Bash(rm -r:*)", "Bash(git push --force:*)"]
```

`PreToolUse` 훅으로 같은 패턴을 또 막으면 이중 확인이 된다. 훅은
**permissions로 표현 못 하는 것**(포매팅, 테스트 자동 실행, 파일 갱신 확인 등)에만 쓴다.

---

## 이 템플릿에 맞는 권장 훅

### 1. 파일 수정 후 formatter/lint

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "<프로젝트 formatter 명령>" }]
      }
    ]
  }
}
```

프로젝트마다 명령이 다르므로 `<프로젝트 formatter 명령>`은 실제 값으로 채운다
(예: `npm run lint:fix`, `black .` 등). 없는 프로젝트라면 이 훅을 추가하지 않는다.

### 2. 위험 명령 확인 (permissions로 못 잡는 것만)

`[safety.permissions]`가 이미 커버하는 패턴은 제외하고, 프로젝트 고유의
위험 명령(예: 특정 배포 스크립트)만 `PreToolUse`로 별도 확인한다.

### 3. 세션 종료 시 `.harness/STATE.md` 갱신 확인

CLAUDE.md는 "작업 시작 전·작업 단위 종료 후마다 `.harness/` 상태 문서를
갱신한다"를 규칙으로 두지만, 강제하는 훅은 없다 — 세션 Claude가 규칙을
따르는지에 의존한다. 자동 강제하려면 `Stop` 훅에서 `.harness/STATE.md`의
mtime이 세션 시작 이후로 갱신됐는지 확인하는 스크립트를 붙인다.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "test $(find .harness/STATE.md -newer /tmp/session-start-marker) || echo 'WARN: STATE.md not updated this session' >&2" }]
      }
    ]
  }
}
```

이 예시는 골격이다 — `/tmp/session-start-marker`를 세션 시작 시 만드는
`SessionStart` 훅과 짝을 이뤄야 실제로 동작한다. 이 템플릿 자체엔 아직
구현돼 있지 않다.

### 4. Acceptance 미실행 상태에서 완료 처리 방지

CLAUDE.md 테스트 규칙(`worker 구현 완료 후, reviewer 검토 전에
agents/test-agent.md 절차를 실행한다`)은 세션 규약이지 훅이 아니다. 기계적으로
강제하려면 Plans.md에서 Task를 `cc:완료`로 바꾸는 Edit를 `PreToolUse`로
가로채 `.harness/LOG.md`에 최근 Acceptance 실행 기록이 있는지 확인하는 훅을
붙일 수 있다 — 다만 이 검증 로직은 프로젝트마다 Task 완료 절차가 다르므로
직접 짜야 한다. 현재 GitHub Actions는 Acceptance 실행을 대신하지 않고
`tasks/index.json`과 `Plans.md`의 검증만 수행한다.

---

## 적용 방법

1. `.claude/settings.local.json`(또는 팀 공유용이면 `.claude/settings.json`)에
   `hooks` 키를 추가한다.
2. Claude Code를 재시작한다 — 훅은 세션 시작 시 로드되므로 실행 중 추가한
   변경은 반영되지 않는다.
3. 의도한 이벤트에서 실제로 실행되는지 짧게 스팟 체크한다(예: 파일 하나
   수정해보고 formatter가 도는지 확인).

---

## 참고

- [../README.md](../README.md#claude-code-hooks) — 요약
- [global-settings-reference.md](./global-settings-reference.md) — `~/.claude/settings.json` 전역 설정 레퍼런스
- `harness.toml`의 `[safety.permissions]`, `[safety.sandbox]` — 이 템플릿의 1차 안전장치
