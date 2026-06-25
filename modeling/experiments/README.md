# 🧪 Modeling Experiments

오늘의 끼니 Modeling 영역의 실험, 검증, 분석, Baseline 비교와 Optimizer 파라미터 튜닝 도구를 관리하는 디렉터리입니다.

`modeling/experiments`는 운영 API 요청을 직접 처리하는 코드가 아니라, 동일한 입력 조건에서 추천·최적화 정책을 반복 실행하고 결과 품질을 비교하기 위한 실험 영역입니다.

```text
Profile 및 Candidate 입력
→ Scenario 또는 Snapshot 구성
→ Recommendation 및 Optimizer 실행
→ Plan Summary와 Validation
→ 결과 Artifact 저장
→ Baseline·정책 간 비교
→ 분석 결과와 개선 후보 도출
```

<br>

## 목차

1. [실험 디렉터리 역할](#1-실험-디렉터리-역할)
2. [운영 코드와 실험 코드의 차이](#2-운영-코드와-실험-코드의-차이)
3. [Directory Structure](#3-directory-structure)
4. [실험 검증 전략](#4-실험-검증-전략)
5. [Scenario Validation](#5-scenario-validation)
6. [Snapshot](#6-snapshot)
7. [Replay](#7-replay)
8. [Baseline](#8-baseline)
9. [Optimizer Tuning](#9-optimizer-tuning)
10. [Validation Pipeline](#10-validation-pipeline)
11. [Analysis 도구](#11-analysis-도구)
12. [Contract 및 Smoke 도구](#12-contract-및-smoke-도구)
13. [Fixture와 Artifact](#13-fixture와-artifact)
14. [실험 결과 해석](#14-실험-결과-해석)
15. [권장 검증 순서](#15-권장-검증-순서)
16. [주요 실행 명령](#16-주요-실행-명령)
17. [현재 구현상 주의사항](#17-현재-구현상-주의사항)
18. [관련 문서](#18-관련-문서)

<br>

## 1. 실험 디렉터리 역할

`modeling/experiments`는 다음 작업을 담당합니다.

```text
검증 Scenario 실행
동일 입력 기반 Snapshot 저장
Optimizer Policy Replay
Baseline 생성
가중치 Grid Search
Validation Summary 생성
실험 결과 비교
RAG 품질 진단
비용·난이도·중복률 분석
Backend Contract 검증
HTTP Smoke Test
```

실험 코드는 운영 요청의 실시간 처리보다 다음 목적에 집중합니다.

```text
재현성
정책 비교
회귀 분석
품질 지표 집계
튜닝 후보 탐색
문제 원인 진단
```

<table style="background-color:#EAF4FF; border-left:6px solid #4D96D9; padding:12px; width:100%;">
  <tr>
    <td>
      <strong>💡 핵심 역할</strong><br>
      Experiment는 추천·최적화 정책의 품질을 검증하는 영역입니다.
      운영 FastAPI Endpoint나 OR-Tools 실행 코드를 대체하지 않으며,
      운영 Service를 다양한 입력과 정책으로 반복 실행하고 결과를 비교합니다.
    </td>
  </tr>
</table>

<br>

## 2. 운영 코드와 실험 코드의 차이

### 운영 Service

관련 위치:

```text
modeling/services/
modeling/api/
```

역할:

```text
실제 Backend 요청 처리
사용자 Profile 생성
RAG 후보 조회
Recommendation 점수 계산
OR-Tools 최적화
Plan 응답 생성
```

### Experiment

관련 위치:

```text
modeling/experiments/
```

역할:

```text
고정 Scenario 실행
Snapshot 기반 재실행
Baseline 생성
Optimizer Policy 비교
검증 지표 집계
결과 Artifact 분석
```

### 역할 관계

```text
운영 Service
→ 실제 Modeling 로직의 Source of Truth

Experiment
→ 운영 Service를 호출해 정책과 결과를 검증
```

Experiment 내부에 비교용 알고리즘이나 Baseline 구현이 있더라도 실제 운영 경로와 동일한 선택 방식이라는 의미는 아닙니다.

<br>

## 3. Directory Structure

```text
modeling/
└── experiments/
    ├── analysis/
    ├── artifacts/
    ├── contract/
    ├── docs/
    ├── fixtures/
    ├── flows/
    ├── optimizer/
    ├── persona/
    ├── pipelines/
    ├── runners/
    ├── scenarios/
    ├── tuning/
    └── README.md
```

### 디렉터리별 역할

| 디렉터리 | 역할 |
|---|---|
| `analysis/` | 실험 결과 비교, 집계와 원인 분석 |
| `artifacts/` | 실행 결과 JSON·CSV·Summary 보관 |
| `contract/` | Backend·Modeling 요청 및 응답 계약 검증 |
| `docs/` | 실험 방법, 검증 기준과 결과 보고서 |
| `fixtures/` | 반복 가능한 요청·응답 입력 데이터 |
| `flows/` | 전체 Modeling 흐름 수동 실행 |
| `optimizer/` | OR-Tools 관련 단독 실험과 진단 |
| `persona/` | Persona 생성 관련 실험 |
| `pipelines/` | 여러 실험 단계를 연결한 통합 검증 |
| `runners/` | Baseline과 개별 실험 실행 진입점 |
| `scenarios/` | 검증 사용자 Scenario 정의 |
| `tuning/` | Snapshot 추출, Replay와 파라미터 탐색 |

실제 디렉터리와 파일은 다음 명령으로 확인합니다.

```bash
find modeling/experiments \
  -maxdepth 2 \
  -type d \
  | sort

find modeling/experiments \
  -type f \
  -name '*.py' \
  | sort
```

<br>

## 4. 실험 검증 전략

실험 검증은 한 번의 실행 결과만 확인하지 않고 다음 단계로 나눕니다.

### 1단계: 정적 검사

```text
Python 문법
Import 경로
CLI 실행 가능 여부
```

### 2단계: Snapshot Replay

```text
고정 Candidate 입력
→ 동일 정책 재실행
→ 코드 변경 전후 결과 비교
```

외부 RAG 변화와 Network 영향을 줄이고 Optimizer 정책 자체를 비교합니다.

### 3단계: Policy Replay

```text
동일 Snapshot
→ Baseline Policy
→ Candidate Policy
→ Conservative Policy
→ 결과 Summary 비교
```

### 4단계: Full Validation

```text
전체 Scenario
→ RAG
→ Recommendation
→ Optimizer
→ Plan
→ Validation
```

실제 전체 파이프라인의 성공률과 품질 지표를 확인합니다.

### 5단계: Monitoring 기준 연결

검증에서 확인한 다음 지표를 운영 관측 기준으로 연결합니다.

```text
solver_success_rate
validation_fail_rate
validation_warning_rate
duplicate_rate
unique_menu_ratio
candidate_to_required_ratio
fallback_rate
rag_quality_issue_rate
runtime p95 / p99
```

<br>

## 5. Scenario Validation

Scenario는 서로 다른 사용자 조건과 식단 제약을 재현하기 위한 검증 입력입니다.

대표 조건:

```text
식비 절약
영양 균형
다이어트
고단백
간편식
맛 중심
낮은 조리 실력
높은 다양성
낮은 예산
복수 목표
```

Scenario Validation은 다음 질문에 답합니다.

```text
모든 Scenario에서 Solver가 실행되는가
예산과 끼니 수 Constraint를 만족하는가
메뉴 반복률이 허용 범위인가
선택 Style이 결과에 반영되는가
조리 난이도가 사용자 조건과 맞는가
Fallback이 과도하게 발생하지 않는가
```

Scenario 정의 위치:

```text
modeling/experiments/scenarios/
```

실제 목록 확인:

```bash
find modeling/experiments/scenarios \
  -type f \
  | sort
```

<br>

## 6. Snapshot

Snapshot은 특정 실행 시점의 Optimizer 재현에 필요한 입력을 저장한 데이터입니다.

대표 포함 정보:

```text
사용자 Profile
선택 Style
Recommendation 결과
Optimizer Candidate
Candidate Score
예산과 기간
Optimizer Config
```

Snapshot은 최종 식단 결과만 저장하는 데이터가 아닙니다.

```text
최종 결과만 저장
→ 원인 분석이 어려움

Optimizer 입력까지 저장
→ 동일 입력으로 정책 재실행 가능
```

### Snapshot의 목적

```text
외부 RAG 응답 변화 제거
동일 Candidate 기반 비교
Optimizer 정책 회귀 확인
가중치 튜닝 재현
문제 Scenario 반복 실행
```

대표 추출 도구:

```text
extract_optimizer_snapshots.py
```

Snapshot에 사용자 민감정보나 운영 Secret을 포함하지 않도록 주의해야 합니다.

<br>

## 7. Replay

Replay는 저장된 Snapshot을 사용해 Recommendation 이후 또는 Optimizer 구간을 다시 실행하는 방식입니다.

```text
Snapshot 입력
→ Candidate 및 Profile 복원
→ 지정한 Optimizer Policy 적용
→ Solver 실행
→ Validation Summary 생성
```

### Replay의 특징

```text
외부 RAG를 다시 호출하지 않음
동일 Candidate 입력 사용
실행 속도가 Full Validation보다 빠름
정책 변경의 영향 분리 가능
```

대표 도구:

```text
replay_optimizer_snapshots.py
replay_optimizer_policy.py
```

### Replay와 Full Validation의 차이

| 항목 | Replay | Full Validation |
|---|---|---|
| 외부 RAG 호출 | 일반적으로 없음 | 포함 가능 |
| Candidate 입력 | Snapshot으로 고정 | 실행 시 생성 |
| 주요 목적 | Optimizer 정책 비교 | 전체 Pipeline 검증 |
| 실행 시간 | 상대적으로 짧음 | 상대적으로 김 |
| RAG 품질 변화 반영 | 어려움 | 가능 |

Replay가 성공해도 실제 RAG 연동과 전체 API 흐름이 정상이라는 의미는 아닙니다.

<br>

## 8. Baseline

Baseline은 개선된 Optimizer 결과를 비교하기 위한 기준 결과입니다.

### MMR Baseline

대표 Runner:

```text
run_baseline_mmr.py
```

MMR 기반으로 메뉴를 구성해 OR-Tools 결과와 비교할 기준을 생성합니다.

```text
MMR Baseline
→ 비교용 실험 정책

운영 OR-Tools 경로
→ OR-Tools가 selected_menu 확정
→ Plan MMR이 alternative_menus 구성
```

따라서 MMR Baseline은 운영 월간 식단 경로와 동일한 선택 방식이 아닙니다.

### Least-cost Baseline

대표 Runner:

```text
run_least_cost_baseline.py
```

비용이 낮은 메뉴를 우선 선택하는 단순 기준 결과를 생성합니다.

비교 목적:

```text
Optimizer가 비용만 최소화하는가
개인화와 영양 점수가 추가 가치를 만드는가
비용 절감과 메뉴 다양성의 Trade-off는 무엇인가
```

### Baseline 해석

```text
Baseline보다 비용이 낮음
≠ 전체 품질이 더 좋음

Baseline보다 중복률이 낮음
≠ 예산과 영양을 모두 만족함

Optimizer 우수성
= 비용 + 개인화 + 영양 + 다양성 + Constraint 만족
```

<br>

## 9. Optimizer Tuning

Optimizer Tuning은 목적함수 가중치와 정책 조합을 변경하며 결과를 비교하는 과정입니다.

대표 조정 항목:

```text
repeat_penalty_weight
repeat_penalty_growth
protein_bonus_weight
difficulty_bonus_weight
solver_time_limit_seconds
candidate_limit
```

대표 도구:

```text
grid_search_optimizer_tuning.py
analyze_tuning_candidates.py
replay_optimizer_policy.py
compare_validation_summaries.py
```

### Grid Search

```text
가중치 조합 생성
→ 동일 Snapshot에 적용
→ Solver 실행
→ Validation Summary 생성
→ 지표별 후보 비교
```

### 정책 선택 기준

하나의 지표만으로 최종 정책을 선택하지 않습니다.

```text
Solver 성공률
Validation Fail
Validation Warning
중복률
고유 메뉴 비율
예산 준수
조리 난이도
Runtime
Fallback
```

### 현재 최종 검증 Override 예시

```json
{
  "repeat_penalty_weight": 4500,
  "protein_bonus_weight": 150,
  "difficulty_bonus_weight": 0,
  "repeat_penalty_growth": "quadratic"
}
```

위 값은 검증 시점의 정책이며, 코드 기본값 또는 운영 고정값과 항상 동일하다고 단정해서는 안 됩니다.

<br>

## 10. Validation Pipeline

대표 Pipeline:

```text
run_final_validation_pipeline.py
run_optimizer_full_validation.py
run_optimizer_validation_pipeline.py
```

### 처리 흐름

```text
Scenario 로드
→ Modeling Pipeline 실행
→ Optimizer 결과 수집
→ Plan Summary 생성
→ Style Validation
→ RAG Diagnostics
→ 전체 Summary 집계
→ Artifact 저장
```

### 대표 결과 지표

```text
scenario_count
success_count
solver_success_rate
solver_status_count
validation_pass_count
validation_warning_count
validation_fail_count
duplicate_rate
unique_menu_ratio
candidate_to_required_ratio
runtime average
runtime p95
runtime p99
rag_quality_issue_count
```

### Validation 상태

```text
pass
→ 주요 품질 기준 만족

warning
→ 식단 생성은 성공했지만 일부 품질 기준 주의 필요

fail
→ 검증 기준을 충족하지 못한 결과
```

Solver가 `OPTIMAL` 또는 `FEASIBLE`이어도 Style Validation은 Warning이나 Fail일 수 있습니다.

```text
Solver 성공
→ 수학적 Constraint를 만족하는 식단 구성 성공

Validation 성공
→ 서비스 품질 기준까지 만족
```

두 결과를 분리해서 해석해야 합니다.

<br>

## 11. Analysis 도구

`analysis/`는 실험 Artifact에서 특정 문제와 지표를 추출합니다.

대표 도구:

```text
analyze_cost_distribution.py
analyze_difficulty_component_replay.py
analyze_difficulty_feasibility.py
analyze_final_validation_result.py
analyze_nutrition_outlier_penalty.py
analyze_rag_difficulty_mapping.py
analyze_style_validation_result.py
analyze_tuning_candidates.py
compare_least_cost_vs_ortools.py
compare_rag_request_results.py
compare_validation_summaries.py
evaluate_baseline_result.py
```

### 분석 범주

```text
비용 분포
난이도 구성 요소
난이도 가능 범위
영양 이상치 Penalty
RAG Mapping 품질
Style Validation 결과
Baseline 대비 개선
튜닝 후보 비교
Validation Summary 차이
```

분석 스크립트는 운영 요청 처리에 사용되지 않습니다.

<br>

## 12. Contract 및 Smoke 도구

`contract/`는 Backend와 Modeling 간 계약과 실제 API 연결을 검증합니다.

대표 도구:

```text
run_backend_contract_validation.py
run_modeling_api_http_smoke.py
run_modeling_service_contract_smoke.py
validate_backend_contract_requests.py
validate_backend_contract_responses.py
analyze_shopping_ingredient_coverage.py
```

### Contract Validation

```text
요청 Fixture
→ 필수 필드와 타입 검사

응답 Fixture
→ Backend가 사용하는 필드와 구조 검사
```

### HTTP Smoke Test

```text
실행 중인 FastAPI
→ /health
→ API Key 인증
→ /metrics
→ /meal-style-candidates 또는 /monthly-plan
```

Contract 및 Smoke 도구는 Experiment 디렉터리에 있지만 추천 품질 튜닝 도구와는 목적이 다릅니다.

```text
Contract / Smoke
→ 연결과 계약 안정성

Scenario / Replay / Tuning
→ 추천·최적화 품질
```

<br>

## 13. Fixture와 Artifact

### Fixture

위치:

```text
modeling/experiments/fixtures/
```

역할:

```text
테스트와 Smoke 실행 입력
Backend 요청·응답 계약
반복 가능한 고정 데이터
```

특징:

```text
작고 안정적임
Git에 저장 가능
변경 시 계약 영향 검토 필요
Secret 포함 금지
```

### Artifact

생성 위치 예시:

```text
modeling/experiments/**/results/
modeling/experiments/artifacts/
```

역할:

```text
실험 실행 결과
Scenario별 상세 JSON
Validation Summary
Policy 비교 결과
Runtime 통계
진단 결과
```

특징:

```text
실행마다 변경 가능
크기가 클 수 있음
일반적으로 Git 추적 제외
필요한 대표 결과만 선별 보관
```

### 관리 원칙

```text
실험 스크립트
→ Git에 커밋

재현 가능한 Fixture
→ 필요 시 Git에 커밋

대용량 실행 Artifact
→ 기본적으로 Git 제외

최종 보고용 Summary
→ 필요성과 크기를 검토한 뒤 선별 커밋
```

실험 결과 파일을 모두 Git에 저장하면 Repository 크기가 증가하고 의미 없는 Diff가 반복될 수 있습니다.

<br>

## 14. 실험 결과 해석

### Solver Success Rate

```text
OPTIMAL 또는 FEASIBLE Scenario 수
÷ 전체 Scenario 수
```

Solver 성공은 Constraint를 만족하는 결과를 찾았다는 의미입니다.

### Duplicate Rate

선택된 대표 메뉴의 반복 정도를 나타냅니다.

```text
duplicate_rate
= 중복 선택 수
÷ 전체 선택 수
```

정확한 산식은 Validation 구현을 기준으로 확인해야 합니다.

### Unique Menu Ratio

```text
unique_menu_ratio
= 고유 selected_menu 수
÷ 전체 selected_menu 수
```

`alternative_menus`는 초기 대표 메뉴 중복률 계산에서 제외될 수 있습니다.

### Candidate Coverage

```text
candidate_to_required_ratio
= 사용 가능한 후보 수
÷ 필요한 전체 끼니 수
```

후보가 많아도 동일 메뉴가 반복되면 `unique_menu_count`가 부족할 수 있습니다.

### Runtime

```text
average
p95
p99
```

평균만 확인하면 일부 느린 Scenario를 놓칠 수 있으므로 p95와 p99를 함께 확인합니다.

### RAG Quality Issue

RAG 품질 이슈는 외부 후보 데이터의 문제를 나타냅니다.

```text
ingredient_groups_empty
mapping_unavailable
protein_zero_or_missing
nutrition_outlier
pricing_fallback
```

RAG 이슈가 있다고 해서 해당 Scenario가 반드시 실패하는 것은 아니지만, Recommendation 점수와 최적화 가능성에 영향을 줄 수 있습니다.

<br>

## 15. 권장 검증 순서

코드 또는 Optimizer 정책을 변경한 뒤 다음 순서로 검증합니다.

### 1단계: Python 문법 검사

```bash
python -m py_compile \
  <변경한 Python 파일>
```

목적:

```text
문법 오류
Import 단계 오류
```

### 2단계: Snapshot Replay

```text
고정 Snapshot
→ 변경 정책 실행
→ 기존 결과와 비교
```

목적:

```text
빠른 회귀 탐지
외부 RAG 변화 제거
```

### 3단계: Policy Replay

```text
Baseline
Candidate-aware
Conservative
변경 Policy
```

목적:

```text
정책별 Trade-off 확인
```

### 4단계: Full Validation

```text
전체 Scenario
→ 실제 Pipeline 실행
→ Summary와 상세 결과 생성
```

목적:

```text
RAG부터 Plan Validation까지 전체 연결 확인
```

### 5단계: Summary 비교

```text
기존 Summary
vs
변경 Summary
```

목적:

```text
성공률
중복률
Runtime
Validation 상태
RAG 품질 영향
```

<table style="background-color:#FFF6C7; border-left:6px solid #E6C85C; padding:12px; width:100%;">
  <tr>
    <td>
      <strong>⭐ 권장 순서</strong><br>
      <code>py_compile → Snapshot Replay → Policy Replay → Full Validation → Summary 비교</code>
      순서로 진행하면 빠른 오류부터 전체 품질 회귀까지 단계적으로 확인할 수 있습니다.
    </td>
  </tr>
</table>

<br>

## 16. 주요 실행 명령

프로젝트 루트에서 실행합니다.

### Final Validation

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/pipelines/run_final_validation_pipeline.py \
  --help
```

### Optimizer Full Validation

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/pipelines/run_optimizer_full_validation.py \
  --help
```

### Baseline MMR

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/runners/run_baseline_mmr.py \
  --help
```

### Least-cost Baseline

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/runners/run_least_cost_baseline.py \
  --help
```

### Snapshot 추출

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/tuning/extract_optimizer_snapshots.py \
  --help
```

### Snapshot Replay

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/tuning/replay_optimizer_snapshots.py \
  --help
```

### Policy Replay

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/tuning/replay_optimizer_policy.py \
  --help
```

### Grid Search

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/tuning/grid_search_optimizer_tuning.py \
  --help
```

### Validation Summary 비교

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/analysis/compare_validation_summaries.py \
  --help
```

### Backend Contract Validation

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/contract/run_backend_contract_validation.py \
  --help
```

### Modeling API HTTP Smoke Test

```bash
PYTHONPATH=modeling \
python \
  modeling/experiments/contract/run_modeling_api_http_smoke.py \
  --help
```

각 스크립트의 실제 CLI 옵션은 실행 시점의 `--help` 출력을 기준으로 확인합니다.

<br>

## 17. 현재 구현상 주의사항

### Experiment는 운영 API 테스트와 동일하지 않음

Scenario와 Replay가 통과해도 다음 항목은 별도로 확인해야 합니다.

```text
FastAPI 인증
실제 HTTP 연결
Docker Port
Nginx
HTTPS
배포 환경 변수
```

해당 항목은 API 테스트, HTTP Smoke Test와 배포 검증의 책임입니다.

### Replay는 외부 RAG 변화를 반영하지 않음

Snapshot Replay는 Candidate 입력을 고정하므로 새로운 RAG 데이터 품질 문제를 발견하기 어렵습니다.

RAG 변경이 포함된 작업은 Full Validation도 수행해야 합니다.

### MMR Baseline은 운영 선택 경로가 아님

MMR Baseline은 비교용 실험 정책입니다.

월간 OR-Tools 운영 경로에서는 다음 순서가 적용됩니다.

```text
Recommendation
→ Optimizer Candidate Builder
→ OR-Tools selected_menu
→ Plan MMR alternative_menus
```

### Snapshot은 입력과 정책 재현용 데이터

Snapshot을 최종 결과 Archive로만 사용하면 Replay 가치가 떨어집니다.

최소한 Optimizer 재실행에 필요한 Profile, Candidate, Score와 Config를 포함해야 합니다.

### Artifact는 기본적으로 Git 제외

실험 결과 전체를 반복 커밋하지 않습니다.

```text
커밋 권장
→ 실행 스크립트
→ 분석 코드
→ 작고 안정적인 Fixture
→ 필요한 대표 Summary

커밋 비권장
→ 대용량 Scenario 결과
→ 실행마다 달라지는 중간 JSON
→ 전체 Raw RAG 응답
→ 일시적인 Grid Search 결과
```

### Summary 필드 간 불일치 확인

집계 Summary와 Scenario 상세 결과의 Pass·Warning·Fail 수가 다르면 집계 코드 또는 결과 해석을 확인해야 합니다.

```text
summary.fail_count
≠ scenario 상세 fail 수
```

이런 불일치는 단순 출력 문제로 넘기지 않고 계산 기준을 추적해야 합니다.

### Baseline 비교는 동일 입력을 사용해야 함

서로 다른 Candidate Pool을 사용하면 알고리즘 차이와 입력 차이를 분리하기 어렵습니다.

```text
동일 Profile
동일 Candidate Pool
동일 기간
동일 예산
동일 Validation 기준
```

가능한 한 위 조건을 고정한 뒤 비교합니다.

### Runtime은 실행 환경의 영향을 받음

Runtime은 다음 요소에 영향을 받습니다.

```text
CPU
Memory
Candidate 수
Solver Time Limit
외부 RAG 응답 시간
Retry 횟수
동시 실행 부하
```

다른 환경의 Runtime을 직접 비교할 때는 실행 조건을 함께 기록해야 합니다.

### 최종 정책은 단일 지표로 선택하지 않음

중복률만 낮추면 비용이나 Runtime이 악화될 수 있습니다.

```text
Solver Success
Validation
Duplicate Rate
Unique Menu Ratio
Budget
Difficulty
RAG Quality
Runtime
```

여러 지표를 함께 확인해야 합니다.

<table style="background-color:#FFF6C7; border-left:6px solid #E6C85C; padding:12px; width:100%;">
  <tr>
    <td>
      <strong>⭐ 설계 요약</strong><br>
      Modeling Experiment는 운영 로직을 복제하는 영역이 아니라,
      동일한 Service 로직을 Scenario·Snapshot·Replay로 반복 실행하여
      정책 변경의 효과와 품질 회귀를 검증하는 영역입니다.<br><br>
      Baseline은 비교 기준으로 사용하고,
      Artifact는 실행 결과로 분리하며,
      최종 정책은 Solver 성공률·중복률·비용·난이도·Runtime과
      Validation 결과를 함께 고려해 결정합니다.
    </td>
  </tr>
</table>

<br>

## 18. 관련 문서

### Experiment 문서

- [`docs/final_validation.md`](docs/final_validation.md)  
  전체 Scenario 실행, 결과 집계와 최종 검증 Pipeline

- [`docs/rag_diagnostics.md`](docs/rag_diagnostics.md)
  RAG Candidate Mapping과 품질 진단

- [`docs/modeling_validation_optimizer_report.md`](docs/modeling_validation_optimizer_report.md)
  Modeling 검증 결과와 Optimizer 정책 분석

- [`docs/optimizer_difficulty_diagnostics.md`](docs/optimizer_difficulty_diagnostics.md)
  조리 난이도 계산과 Validation 진단

### Repository 문서

- [`../README.md`](../README.md)
  Modeling 전체 아키텍처와 실행 흐름

- [`../services/recommendation/README.md`](../services/recommendation/README.md)
  후보별 적합도 점수와 `final_score` 계산

- [`../services/optimizer/README.md`](../services/optimizer/README.md)
  OR-Tools Constraint, Objective, 후보 구성과 Retry

- [`../services/plan/README.md`](../services/plan/README.md)
  `selected_menu`, MMR 대체 메뉴, Summary와 Validation

- [`../tests/README.md`](../tests/README.md)
  Pytest, Contract, Smoke와 Experiment의 검증 범위

### Notion 문서

- [🔁 Validation 실행 자동화 및 재현성](https://app.notion.com/p/Validation-3829e3e335cc8081bd73f6be2c803c1b?source=copy_link)  
  전체 검증 Pipeline 자동화, 동일 입력 기반 재실행, 결과 저장과 비교를 통한 재현성 확보 과정