# HANDOFF.md — Task 인수인계 템플릿

> 이 루트 파일은 실제 인수인계가 아니라 템플릿이다.
> 기본 복사 대상이 아니다. 실제로 필요할 때만 `.harness/tasks/<task-key>/HANDOFF.md`로 복사해서 사용한다.

## 다음 세션이 먼저 읽을 최소 파일

1. `.harness/tasks/<task-key>/STATE.md`
2. `.harness/LESSONS.md` 최근 항목
3. `tasks/index.json`
4. `Plans.md`
5. `.harness/CONTEXT_INDEX.md`에서 필요한 파일

## 재개 지점

- [어디서 이어가면 되는지 기록]

## 주의사항

- Task 상태의 단일 출처는 `tasks/index.json`이다.
- 루트 `.harness/*.md` 템플릿에 실제 진행 상태를 기록하지 않는다.
