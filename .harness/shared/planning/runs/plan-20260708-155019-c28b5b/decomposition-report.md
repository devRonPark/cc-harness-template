# Decomposition Report — Task별 .harness 맥락 디렉토리 도입

## 완료 기준

- 루트 `.harness/*.md`는 복사용 템플릿 역할로 정리된다.
- 실제 작업 맥락은 `.harness/tasks/<task-key>/` 아래 Task별 파일로 기록된다.
- 최근 완료된 `4.11` 맥락과 중단된 README 개편 맥락만 새 구조 예시로 이관된다.
- `CLAUDE.md`, `AGENTS.md`, Codex skill, recovery/error 문서, skeleton이 같은 구조를 설명한다.

## 확인 방법

Acceptance 명령은 새 Task별 디렉토리, skeleton `.gitkeep`, 핵심 문구, task/plan sync를 확인한다. 추가 검증으로 관련 unittest와 `init.sh` smoke test를 실행한다.

## 먼저 끝나야 할 작업

`4.11`의 rescue-from-main helper 맥락을 이관 예시로 사용하므로 `4.11` 완료에 의존한다.
