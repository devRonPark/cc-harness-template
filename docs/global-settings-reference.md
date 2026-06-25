# 전역 설정 레퍼런스 — `~/.claude/settings.json`

이 파일은 모든 프로젝트에 전역으로 적용되는 Claude Code 설정이다.
프로젝트별 설정은 `.claude/settings.local.json`에 분리한다.

---

## 완성본 예시

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

---

## 각 항목 설명

### `enabledPlugins`

Plugin ID → `true/false` 맵. `false`로 설정하면 설치는 유지되지만 비활성화.

### `extraKnownMarketplaces`

Claude Code 공식 마켓플레이스 외에 커스텀 소스를 등록하는 섹션.
`source.github` → GitHub repo, `source.git` → 임의 Git URL.

### `tui`

터미널 UI 모드. `fullscreen`이 기본 권장값 (전체화면 인터페이스).

### `theme`

`dark` / `light` / `auto`.

---

## 프로젝트 스코프 권한 설정

전역이 아닌 특정 프로젝트에만 적용할 권한은 `.claude/settings.local.json`에 기입.

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)"
    ]
  }
}
```

`allow` 목록에 없는 명령은 실행 전 사용자 확인 요청.
`harness.toml`의 `deny` / `ask` 규칙이 여기보다 우선 적용된다.
