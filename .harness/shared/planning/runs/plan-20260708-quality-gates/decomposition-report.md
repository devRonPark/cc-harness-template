# Quality Gate Task Proposal

## 완료 기준

- Claude-only plugin enhancement인 ponytail/caveman과 Codex 공통 품질 규칙의 경계를 문서화한다.
- `agents/quality-gates.md`를 공통 절차 문서로 추가한다.
- Codex harness skills가 구현 전 scope/YAGNI 체크와 리뷰 findings 기준을 같은 문서에서 참조한다.
- README, BLUEPRINT, AGENTS, init skeleton, context index가 새 품질 게이트의 역할을 설명한다.

## 확인 방법

- proposal의 Acceptance 명령은 계획 문서와 품질 게이트 파일 존재를 확인한다.
- `YAGNI`, `caveman`, `agents/quality-gates.md` 핵심 연결 문구를 grep으로 확인한다.
- 전체 Task 검증과 Plans sync check는 구현 후 별도로 실행한다.

## 먼저 끝나야 할 작업

- Codex skill 골격이 있어야 연결할 수 있으므로 `4.8`을 Depends로 둔다.

## 분해 판단

이 작업은 문서와 절차 연결만 다루며 런타임 기능 변경을 포함하지 않는다. 산출물이 하나의 품질 게이트 기준으로 묶여 있고 독립 acceptance가 있으므로 추가 분해하지 않는다.
