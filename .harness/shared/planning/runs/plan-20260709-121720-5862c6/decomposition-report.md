# Superpowers benchmark 적용 Task proposal

## 완료 기준

- 4.14는 사용자-facing rulebook과 구조 문서가 같은 핵심 흐름을 말하게 한다.
- 4.15는 Task 분해 기준에 Files, Interfaces, Verification, no-placeholder 검사를 추가한다.
- 4.16은 TDD evidence와 fresh verification evidence를 완료 전 필수 조건으로 만든다.
- 4.17은 review verdict를 Spec compliance와 Code quality 두 축으로 나눈다.
- 4.18은 git helper가 branch/worktree 상태와 PR 전 verification evidence를 확인하게 한다.
- 4.19는 skeleton RUN_REPORT evidence 표를 새 완료 조건에 맞춘다.

## 확인 방법

각 Task는 repo 루트에서 실행 가능한 `grep` 기반 Acceptance를 가진다. 문서 변경 Task라 런타임 테스트 대신 문구 존재와 전체 task/plans 검증으로 판정한다.

## 먼저 끝나야 할 작업

4.14가 전체 흐름의 기준을 먼저 세운다. TDD/verification gate인 4.16 이후 review, git helper, skeleton evidence 변경을 적용한다.
