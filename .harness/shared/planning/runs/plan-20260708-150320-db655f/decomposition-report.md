# decomposition report — rescue-from-main helper

## 결과

새 Task `4.11` 하나로 분해한다.

## 완료 기준

`rescue-from-main`은 기존 Git workflow helper 묶음의 후속 산출물이다. Claude Code
custom command와 Codex skill, 사용자 진입점 문서, 초기화 복사 경로가 함께 등록되어야
사용자가 같은 절차를 양쪽 런타임에서 실행할 수 있다.

## 확인 방법

Acceptance는 새 command/skill 파일 존재와 `AGENTS.md`, `README.md`, `BLUEPRINT.md`
등록 문구를 확인한다. 추가 검증으로 task sync, skill frontmatter, init smoke test를
실행한다.

## 먼저 끝나야 할 작업

기존 Git helper 구조와 공용 quality gate가 필요하므로 `4.9`, `4.10`에 의존한다.
