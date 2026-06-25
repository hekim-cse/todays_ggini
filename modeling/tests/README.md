# 🧪 Modeling Test Guide

오늘의 끼니 Modeling 영역의 자동화 테스트, API 계약 검증, HTTP Smoke Test와 품질 실험의 역할을 정리한 문서입니다.

테스트는 빠르게 반복 실행할 수 있는 Pytest 기반 검증, 실제 실행 중인 FastAPI 컨테이너를 호출하는 HTTP Smoke Test, 전체 추천·최적화 품질을 평가하는 Experiment Validation으로 구분합니다.

```text
Source Code
    ↓
정적 검사
    ↓
Pytest Unit / API / Contract Test
    ↓
Docker Image Build
    ↓
Container Health & Metrics Check
    ↓
HTTP Smoke Test
    ↓
Scenario / Replay / Experiment Validation
```

각 테스트 계층은 서로 다른 문제를 검증합니다.

```text
API Test
→ 요청 검증, 인증, 오류 상태, Metrics, Service 호출 경계

Service Test
→ Profile, RAG, Recommendation, Optimizer, Plan 로직

Contract Test
→ Backend와 약속한 요청·응답 구조

HTTP Smoke Test
→ 실제 Process, Container, Network, Header와 Endpoint 연결

Experiment Validation
→ 추천 품질, Solver 성공률, 중복률, Runtime과 정책 비교
```

<br>

## 목차

1. [테스트 목적](#1-테스트-목적)
2. [테스트 전략](#2-테스트-전략)
3. [디렉터리 구조](#3-디렉터리-구조)
4. [현재 테스트 현황](#4-현재-테스트-현황)
5. [API Request Validation 테스트](#5-api-request-validation-테스트)
6. [API 인증 테스트](#6-api-인증-테스트)
7. [Prometheus Metrics 테스트](#7-prometheus-metrics-테스트)
8. [RAG 오류 상태 매핑 테스트](#8-rag-오류-상태-매핑-테스트)
9. [Backend 응답 Contract 테스트](#9-backend-응답-contract-테스트)
10. [Optimizer 결과 매핑 테스트](#10-optimizer-결과-매핑-테스트)
11. [Persona 테스트](#11-persona-테스트)
12. [Fixture](#12-fixture)
13. [Monkeypatch 사용](#13-monkeypatch-사용)
14. [전체 Pytest 실행](#14-전체-pytest-실행)
15. [범주별 테스트 실행](#15-범주별-테스트-실행)
16. [HTTP Smoke Test](#16-http-smoke-test)
17. [Smoke Test 검증 범위](#17-smoke-test-검증-범위)
18. [Docker 통합 검증](#18-docker-통합-검증)
19. [CI 테스트 흐름](#19-ci-테스트-흐름)
20. [Pytest와 Experiment의 차이](#20-pytest와-experiment의-차이)
21. [Experiment Validation 도구](#21-experiment-validation-도구)
22. [테스트 실패 해석](#22-테스트-실패-해석)
23. [테스트 작성 규칙](#23-테스트-작성-규칙)
24. [현재 테스트 공백](#24-현재-테스트-공백)
25. [권장 보강 순서](#25-권장-보강-순서)
26. [관련 문서](#26-관련-문서)

<br>

## 1. 테스트 목적

Modeling 테스트는 다음 문제를 조기에 발견하는 것을 목표로 합니다.

```text
API 요청 Schema 변경
API Key 인증 누락
Backend 응답 Contract 변경
RAG 오류 상태 코드 오분류
Prometheus Metric 누락
Optimizer 결과 매핑 오류
OR-Tools 대표 메뉴 변경 또는 누락
대체 메뉴 중복
Persona 생성 회귀
Docker 이미지 실행 실패
실행 서버와 코드 간 통합 오류
추천·최적화 품질 회귀
```

모델링 품질은 단순히 함수가 오류 없이 실행되는 것만으로 보장되지 않습니다.

따라서 테스트를 다음 두 축으로 나눕니다.

```text
기능·계약 안정성
→ Pytest / Contract / HTTP Smoke Test

추천·최적화 결과 품질
→ Scenario / Snapshot / Replay / Experiment Validation
```

<table style="background-color:#EAF4FF; border-left:6px solid #4D96D9; padding:12px; width:100%;">
  <tr>
    <td>
      <strong>💡 테스트 계층 구분</strong><br>
      API 테스트가 OR-Tools 목적함수나 MMR 품질까지 직접 검증하는 것은 아닙니다.
      API 테스트는 요청·인증·응답·오류 처리 경계를 검증하고,
      실제 추천 점수와 Solver 결과는 Service 테스트와 Experiment Validation에서 검증합니다.
    </td>
  </tr>
</table>

<br>

## 2. 테스트 전략

### 1단계: 정적 검증

```text
Python 문법 오류
Import 오류
잘못된 모듈 경로
README 및 설정 파일의 공백 오류
```

대표 명령:

```bash
python -m py_compile \
  modeling/api/server.py \
  modeling/api/metrics.py

git diff --check
```

### 2단계: 빠른 단위·API 테스트

```text
Pydantic Validation
API Key
오류 상태 매핑
Metrics
응답 Contract
결과 Mapper
Service 함수 단위 동작
```

대표 도구:

```text
pytest
FastAPI TestClient
monkeypatch
고정 JSON Fixture
```

이 단계에서는 가능한 한 외부 네트워크와 실제 RAG Service 의존성을 제거합니다.

### 3단계: 실행 서버 Smoke Test

```text
Docker Container
Uvicorn
HTTP Port
API Key
Health Endpoint
Metrics Endpoint
실제 HTTP 요청
```

Smoke Test는 실제 Process와 Network 경계를 확인하지만, 모든 추천 품질과 Solver 제약조건을 검증하지는 않습니다.

### 4단계: 품질 검증

```text
RAG 후보 품질
Recommendation 점수
Optimizer 성공률
선택 메뉴 중복률
Style Validation
Runtime
Fallback
정책별 결과 차이
```

이 단계는 `modeling/experiments`의 Pipeline, Snapshot과 Replay 도구가 담당합니다.

<br>

## 3. 디렉터리 구조

```text
modeling/
├── tests/
│   ├── __init__.py
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   ├── test_modeling_api_metrics.py
│   │   ├── test_modeling_api_rag_error_status.py
│   │   └── test_modeling_api_request_validation.py
│   │
│   ├── contract/
│   │   ├── __init__.py
│   │   └── test_optimizer_failure_response_contract.py
│   │
│   ├── optimizer/
│   │   ├── __init__.py
│   │   └── test_ortools_alternative_menus.py
│   │
│   ├── persona/
│   │   ├── __init__.py
│   │   └── test_persona_profile_build.py
│   │
│   └── README.md
│
├── experiments/
│   ├── fixtures/
│   ├── contract/
│   ├── pipelines/
│   ├── runners/
│   ├── tuning/
│   ├── analysis/
│   └── artifacts/
│
└── api/
    ├── server.py
    └── metrics.py
```

실제 파일과 디렉터리 구성은 작업 시점에 따라 달라질 수 있으므로 다음 명령으로 최신 상태를 확인합니다.

```bash
find modeling/tests \
  -maxdepth 3 \
  -type f \
  | sort

find modeling/experiments \
  -maxdepth 2 \
  -type d \
  | sort
```

<br>

## 4. 현재 테스트 현황

테스트 파일과 테스트 함수 수는 코드 변경에 따라 달라질 수 있습니다.

README에 적힌 숫자를 고정된 품질 지표로 사용하지 않고, 실행 시점에 Pytest Collection 결과를 기준으로 확인합니다.

### 테스트 파일 확인

```bash
find modeling/tests \
  -type f \
  -name 'test_*.py' \
  | sort
```

### 테스트 파일 수 확인

```bash
find modeling/tests \
  -type f \
  -name 'test_*.py' \
  | wc -l
```

### 전체 테스트 목록 확인

```bash
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests \
  --collect-only \
  -q
```

소스에서 테스트 정의를 빠르게 찾으려면 다음 명령을 사용할 수 있습니다.

```bash
grep -RInE \
  --include='*.py' \
  --exclude-dir='__pycache__' \
  '^def test_|^async def test_|^class Test' \
  modeling/tests
```

### 범주별 확인

```bash
for test_dir in api contract optimizer persona; do
  echo "[$test_dir]"
  find "modeling/tests/$test_dir" \
    -type f \
    -name 'test_*.py' \
    2>/dev/null \
    | sort
done
```

<table style="background-color:#FFF6C7; border-left:6px solid #E6C85C; padding:12px; width:100%;">
  <tr>
    <td>
      <strong>⭐ 최신 상태 기준</strong><br>
      테스트 개수는 구현이 추가될 때마다 변경됩니다.
      문서의 과거 숫자보다 <code>pytest --collect-only</code> 결과와
      CI 실행 결과를 최신 기준으로 사용합니다.
    </td>
  </tr>
</table>

<br>

## 5. API Request Validation 테스트

관련 파일:

```text
modeling/tests/api/test_modeling_api_request_validation.py
```

FastAPI `TestClient`를 사용해 HTTP 요청 검증과 Service 연결을 확인합니다.

```python
client = TestClient(server.app)
```

### Monthly Plan 요청 검증

대표 검증 항목:

```text
빈 요청 → HTTP 422
id 누락 → HTTP 422
잘못된 request_type → HTTP 422
profile 누락 → HTTP 422
selected_style 누락 → HTTP 422
selected_style 내부 필드 누락 → HTTP 422
monthly_budget = 0 → HTTP 422
정상 요청 → create_monthly_plan() 호출
API Key 누락 → HTTP 401
```

### Meal Style Candidates 요청 검증

```text
빈 요청 → HTTP 422
잘못된 request_type → HTTP 422
정상 요청 → create_meal_style_candidates() 호출
```

### 검증 목적

이 테스트는 실제 Endpoint에 HTTP 요청을 보내 다음 API 경계를 확인합니다.

```text
JSON 요청
→ FastAPI Routing
→ Pydantic 검증
→ API 인증
→ Payload 변환
→ Service 함수 전달
→ HTTP 응답
```

정상 요청 테스트에서는 `create_monthly_plan()` 또는 `create_meal_style_candidates()`를 Monkeypatch하여 Service 호출 여부와 전달 Payload를 확인할 수 있습니다.

### 검증하지 않는 범위

API Request Validation 테스트는 다음 내부 알고리즘을 직접 검증하지 않습니다.

```text
RAG 후보 검색 품질
Recommendation Score 공식
OR-Tools Constraint와 Objective
selected_menu 최적화 품질
MMR alternative_menus 품질
Style Validation Threshold
```

해당 항목은 Service 테스트와 Experiment Validation의 책임입니다.

<br>

## 6. API 인증 테스트

테스트용 Header:

```python
TEST_API_KEY = "ci-secret-key"

AUTH_HEADERS = {
    "X-API-Key": TEST_API_KEY,
}
```

대표 검증:

```text
정상 API Key
→ Endpoint Service까지 요청 전달

API Key 누락
→ HTTP 401

잘못된 API Key
→ HTTP 401
```

운영 환경에서 `MODELING_API_KEY` 자체가 설정되지 않은 경우에는 서버 설정 오류인 HTTP `500` 경로도 별도로 검증할 수 있습니다.

API Key 자체가 Git에 저장된 운영 Secret을 의미하지는 않습니다.

`ci-secret-key`, `metrics-test-key`, `local-secret-key`와 같은 값은 테스트 격리용 고정 문자열입니다.

운영 Secret은 GitHub Actions Secret, EC2 환경 변수 또는 Secret Manager를 통해 관리해야 합니다.

<br>

## 7. Prometheus Metrics 테스트

관련 파일:

```text
modeling/tests/api/test_modeling_api_metrics.py
```

대표 테스트 범위:

```text
운영 /metrics API Key 인증
Prometheus Content 반환
비즈니스 요청 Metric 기록
알 수 없는 Path의 /unmatched 정규화
/health와 /metrics 집계 제외
422 Validation 오류 기록
401 인증 오류 기록
504 RAG Timeout 기록
502 RAG Upstream 오류 기록
500 내부 오류 기록
```

최신 테스트 이름은 다음 명령으로 확인합니다.

```bash
grep -nE \
  '^def test_|^async def test_|^class Test' \
  modeling/tests/api/test_modeling_api_metrics.py
```

### `/metrics` 인증

```text
ENV=prod
+ API Key 없음
→ HTTP 401
```

정상 API Key가 있으면 Prometheus Text 형식의 응답을 반환합니다.

### 요청 Count 기록

예를 들어 잘못된 Monthly Request를 보내 HTTP `422`가 발생하면 다음 Label을 가진 Metric이 증가하는지 확인합니다.

```text
method="POST"
path="/monthly-plan"
status_code="422"
```

대상 Metric:

```text
modeling_http_requests_total
```

### 알 수 없는 Path 정규화

임의 사용자 입력 Path를 Metric Label로 직접 사용하지 않습니다.

```text
/arbitrary-user-controlled-path
→ /unmatched
```

테스트는 원본 임의 Path가 Metrics 응답에 나타나지 않는지 확인합니다.

### 집계 제외 Path

```text
/health
/metrics
```

위 요청은 비즈니스 요청 Metric에 기록되지 않아야 합니다.

### 오류 유형

대표적인 의미 기반 오류 유형:

| Error Type | HTTP Status |
|---|---:|
| `validation` | 422 |
| `authentication` | 401 |
| `rag_timeout` | 504 |
| `rag_upstream` | 502 |
| `unexpected` | 500 |

Metrics 테스트는 추천 결과의 품질을 검증하는 테스트가 아니라, HTTP 요청과 오류가 올바른 Label로 관측되는지 검증하는 테스트입니다.

<br>

## 8. RAG 오류 상태 매핑 테스트

관련 파일:

```text
modeling/tests/api/test_modeling_api_rag_error_status.py
```

검증 함수:

```python
get_rag_error_status_code(
    error: RagRequestError,
) -> int
```

대표 테스트 Case:

| Failure Reason | 예상 HTTP Status |
|---|---:|
| `rag_read_timeout` | 504 |
| `rag_timeout` | 504 |
| `rag_connection_error` | 502 |
| `rag_request_error` | 502 |
| `rag_http_error` | 502 |

### 의미

```text
504 Gateway Timeout
→ 외부 RAG Service가 제한 시간 내 응답하지 않음

502 Bad Gateway
→ RAG 연결, 요청 또는 Upstream HTTP 오류
```

RAG 원본 상태가 `500`이어도 Modeling API는 외부 의존성 장애라는 의미를 유지하기 위해 `502`로 변환할 수 있습니다.

### 테스트 범위

이 테스트는 다음 경계만 확인합니다.

```text
RagRequestError.failure_reason
→ Modeling API HTTP Status
```

다음 항목은 확인하지 않습니다.

```text
실제 RAG 검색 결과 품질
RAG 후보 개수
RAG Mapping 정확도
최종 월간 식단 품질
```

### Pytest 없이 독립 실행

해당 파일이 독립 실행 진입점을 제공하는 경우 다음 명령으로 확인할 수 있습니다.

```bash
PYTHONPATH=modeling \
python \
  modeling/tests/api/test_modeling_api_rag_error_status.py
```

<br>

## 9. Backend 응답 Contract 테스트

관련 파일:

```text
modeling/tests/contract/test_optimizer_failure_response_contract.py
```

Contract Test는 내부 구현 방식보다 Backend와 약속한 응답 필드를 우선 검증합니다.

### UNKNOWN 실패 응답

```text
request_type = monthly_plan
success = False
failure_reason = optimizer_unknown
optimizer.solver_status = UNKNOWN
monthly_plan.days = []
```

### INFEASIBLE 실패 응답

```text
failure_reason = optimizer_infeasible
optimizer.solver_status = INFEASIBLE
```

### Dispatcher 검증

```text
UNKNOWN
→ build_optimizer_unknown_monthly_response()

INFEASIBLE
→ build_optimizer_infeasible_monthly_response()
```

잘못된 Builder가 호출되면 테스트가 실패하도록 구성할 수 있습니다.

### 성공 응답

```text
id 유지
request_type = monthly_plan
success = True
failure_reason = None
```

### 중요성

Optimizer 내부 Policy가 변경되더라도 Backend가 해석하는 다음 계약은 유지되어야 합니다.

```text
id
success
failure_reason
request_type
monthly_plan
optimizer.solver_status
days
```

Contract Test는 추천 품질을 판단하지 않습니다.

```text
검증함
→ 필드 존재 여부, 타입, 상태 값과 실패 응답 구조

검증하지 않음
→ selected_menu가 최적의 메뉴인지
→ 중복률과 영양 품질이 충분한지
→ Runtime이 운영 목표를 만족하는지
```

<br>

## 10. Optimizer 결과 매핑 테스트

관련 파일:

```text
modeling/tests/optimizer/test_ortools_alternative_menus.py
```

테스트 대상:

```python
build_ortools_monthly_plan()
```

### OR-Tools 대표 메뉴 유지

월간 OR-Tools 경로에서 Solver가 선택한 메뉴는 Plan의 `selected_menu`로 유지되어야 합니다.

```text
OR-Tools selected item
→ selected_menu
→ Plan 후처리에서 교체하지 않음
```

### 대체 메뉴 정상 생성

대표 검증 내용:

```text
OR-Tools selected_menu 유지
alternative_menus 생성
selected_menu ID 제외
alternative_menus 내부 ID 중복 방지
```

MMR은 이 단계에서 OR-Tools가 확정한 대표 메뉴를 다시 선택하지 않습니다.

```text
OR-Tools
→ selected_menu 확정

Plan MMR
→ selected_menu 유지
→ alternative_menus 구성
```

### 대체 후보 없음

Recommendation 결과에 대표 메뉴 외의 사용 가능한 후보가 없으면 다음 구조를 유지하는지 확인합니다.

```json
{
  "alternative_menus": []
}
```

### 현재 범위

이 테스트는 OR-Tools Solver 자체보다 Solver 결과를 Plan 구조로 변환하는 `result_mapper`와 대체 메뉴 후처리를 검증합니다.

다음 Solver 핵심 항목은 별도 단위·통합 테스트 보강 대상입니다.

```text
각 Slot에 정확히 한 메뉴
월 예산 상한
동일 메뉴 최대 반복
Objective 가중치
OPTIMAL / FEASIBLE / UNKNOWN / INFEASIBLE 처리
후보 부족 사전 검사
예산 불가능 사전 검사
```

<table style="background-color:#EAF4FF; border-left:6px solid #4D96D9; padding:12px; width:100%;">
  <tr>
    <td>
      <strong>💡 테스트 대상 구분</strong><br>
      파일명이 OR-Tools를 포함하더라도 현재 테스트의 핵심 대상은
      Solver 수학 모델 전체가 아니라 Solver 결과의 Plan Mapping과
      <code>alternative_menus</code> 후처리일 수 있습니다.
    </td>
  </tr>
</table>

<br>

## 11. Persona 테스트

관련 파일:

```text
modeling/tests/persona/test_persona_profile_build.py
```

Persona 테스트는 초기 온보딩 데이터를 기반으로 Persona Profile과 후보를 생성하는 흐름의 회귀를 확인합니다.

최신 테스트 이름과 Assertion 확인:

```bash
grep -nE \
  '^def test_|^async def test_|^class Test|assert ' \
  modeling/tests/persona/test_persona_profile_build.py
```

실행:

```bash
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests/persona \
  -q
```

Persona Profile Build의 상세 입력과 출력 구조는 다음 문서를 참고합니다.

```text
modeling/services/persona/README.md
modeling/services/profile/README.md
```

Persona 테스트는 월간 OR-Tools 식단이나 Plan MMR을 직접 검증하지 않습니다.

```text
Persona
→ 사용자·가구 조건 정규화
→ 권장 칼로리와 Persona 후보 생성

Monthly Plan
→ 이후 Profile, RAG, Recommendation, Optimizer와 Plan 단계에서 처리
```

<br>

## 12. Fixture

Fixture 위치:

```text
modeling/experiments/fixtures/
```

대표 Fixture:

```text
backend_monthly_plan_request.json
backend_monthly_plan_success_response.json
backend_monthly_plan_failure_response.json
backend_style_candidates_request.json
backend_style_candidates_response.json
```

실제 목록은 다음 명령으로 확인합니다.

```bash
find modeling/experiments/fixtures \
  -maxdepth 1 \
  -type f \
  | sort
```

### 요청 Fixture

```text
backend_monthly_plan_request.json
backend_style_candidates_request.json
```

Backend가 Modeling API에 보내는 요청 구조를 고정합니다.

사용 위치:

```text
API Request Validation Test
API Metrics Test
HTTP Smoke Test
Contract Validation
```

### 응답 Fixture

```text
backend_monthly_plan_success_response.json
backend_monthly_plan_failure_response.json
backend_style_candidates_response.json
```

Backend와 Modeling의 응답 계약을 비교하거나 문서 예시로 사용할 수 있습니다.

### Fixture 사용 원칙

```text
실제 Backend 계약과 최대한 동일하게 유지
테스트 전용 임의 필드 추가 최소화
Secret 포함 금지
사용자 민감정보 포함 금지
실행 결과 전체 Dump를 Fixture로 사용하지 않음
변경 시 Backend 영향 확인
```

### Fixture와 Artifact 차이

```text
Fixture
→ 테스트 입력·기대값으로 Git에 저장
→ 작고 안정적이며 반복 사용
→ 테스트 재현을 위한 기준 데이터

Artifact
→ 실험 실행 결과
→ 크고 실행마다 달라질 수 있음
→ 분석·비교를 위한 결과 데이터
→ 일반적으로 Git 추적 대상에서 제외하거나 선별 보관
```

Fixture를 변경하는 작업은 단순 데이터 수정이 아니라 테스트 계약 변경일 수 있으므로 관련 테스트와 Backend 문서를 함께 확인해야 합니다.

<br>

## 13. Monkeypatch 사용

API와 Contract 테스트에서는 실제 외부 Service 호출을 막고 전달 Payload를 검증하기 위해 `monkeypatch`를 사용합니다.

예시:

```python
monkeypatch.setattr(
    server,
    "create_monthly_plan",
    fake_create_monthly_plan,
)
```

### 목적

```text
실제 RAG API 호출 방지
테스트 속도 향상
네트워크 상태와 테스트 분리
Service 전달 Payload 확인
특정 오류를 결정적으로 재현
외부 Service 장애 상황 재현
```

### API 테스트의 일반적인 흐름

```text
FastAPI Endpoint
→ Monkeypatch된 Service 함수 호출
→ 고정된 응답 또는 예외 반환
→ HTTP Status와 Response 검증
```

### 주의점

Monkeypatch 기반 테스트가 성공해도 다음 항목이 정상이라는 뜻은 아닙니다.

```text
실제 RAG 연결
Docker Network
운영 환경 변수
실제 Recommendation Score
OR-Tools Solver 실행
Plan MMR 품질
```

실제 실행 환경은 HTTP Smoke Test로, 추천·최적화 품질은 Experiment Validation으로 별도 검증해야 합니다.

또한 Patch 대상은 함수가 정의된 원본 모듈이 아니라 테스트 대상 코드가 참조하는 Namespace를 기준으로 선택해야 합니다.

<br>

## 14. 전체 Pytest 실행

프로젝트 루트에서 실행합니다.

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests \
  -q
```

### 옵션 설명

```text
ENV=prod
→ 운영 인증·문서 비활성화 조건으로 테스트

MODELING_API_KEY=ci-secret-key
→ 보호 Endpoint 테스트용 Key

PYTHONPATH=modeling
→ api, services, schemas를 최상위 Package처럼 Import

python -m pytest
→ 현재 Python 가상환경의 Pytest 실행

-q
→ 간략한 결과 출력
```

### 테스트 목록만 확인

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests \
  --collect-only \
  -q
```

### Cache Provider 비활성화

CI에서는 다음 옵션을 사용할 수 있습니다.

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  -q \
  -p no:cacheprovider \
  modeling/tests
```

`.pytest_cache`를 생성하지 않고 테스트합니다.

### 상세 실패 확인

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests \
  -vv \
  --tb=short
```

<br>

## 15. 범주별 테스트 실행

### API 전체

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests/api \
  -q
```

### Contract

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests/contract \
  -q
```

### Optimizer 및 결과 Mapping

```bash
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests/optimizer \
  -q
```

### Persona

```bash
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests/persona \
  -q
```

### 특정 파일

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests/api/test_modeling_api_metrics.py \
  -q
```

### 특정 함수

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests/api/test_modeling_api_metrics.py::test_rag_timeout_error_is_recorded \
  -q
```

### 실패한 테스트만 재실행

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  modeling/tests \
  --lf \
  -q
```

<br>

## 16. HTTP Smoke Test

관련 파일:

```text
modeling/experiments/contract/run_modeling_api_http_smoke.py
```

Pytest의 `TestClient`가 아니라 HTTP Client를 이용해 실제 실행 중인 Modeling API Server를 호출합니다.

### 기본 실행

```bash
python \
  modeling/experiments/contract/run_modeling_api_http_smoke.py \
  --base-url http://127.0.0.1:8001 \
  --api-key local-secret-key
```

대표 기본값:

```text
base-url = http://localhost:8001
api-key = local-secret-key
timeout = 60초
monthly fixture = backend_monthly_plan_request.json
```

정확한 옵션은 다음 명령으로 확인합니다.

```bash
python \
  modeling/experiments/contract/run_modeling_api_http_smoke.py \
  --help
```

### Monthly API 생략

외부 RAG 의존성을 피해야 하는 CI에서는 다음 옵션을 사용할 수 있습니다.

```bash
python \
  modeling/experiments/contract/run_modeling_api_http_smoke.py \
  --base-url http://127.0.0.1:8001 \
  --api-key local-secret-key \
  --skip-monthly
```

### Smoke Test 역할

```text
확인함
→ Process 기동
→ Port 접근
→ Header 전달
→ FastAPI Routing
→ 인증
→ HTTP Status와 기본 응답 구조

완전히 확인하지 않음
→ 모든 OR-Tools Constraint
→ 모든 Style Validation 경계
→ 전체 추천 품질
→ 장기 Runtime 안정성
```

<br>

## 17. Smoke Test 검증 범위

### Health Check

```text
GET /health
→ HTTP 200
→ status = ok
→ service = todays-ggini-modeling
```

현재 Health Check는 FastAPI Process가 응답하는지 확인하는 Liveness 성격이 강합니다.

외부 RAG, Solver와 전체 파이프라인 정상 여부를 모두 보장하지는 않습니다.

### 잘못된 API Key

```text
POST /monthly-plan
X-API-Key = wrong-key
→ HTTP 401
```

### Docs 상태

```text
GET /docs

Local
→ 200 가능

Docker / Prod
→ 404 예상
```

Smoke Test가 여러 실행 환경을 지원한다면 `200` 또는 `404`를 허용할 수 있습니다.

### Monthly Plan

실행 환경과 Smoke Script 정책에 따라 다음 응답을 처리할 수 있습니다.

```text
200
→ RAG와 전체 Modeling 파이프라인이 응답을 반환함

502
→ RAG Upstream 오류가 Bad Gateway로 분리됨

504
→ RAG Timeout이 Gateway Timeout으로 분리됨
```

HTTP `200`이면 다음과 같은 기본 응답 구조를 추가 검증할 수 있습니다.

```text
request_type = monthly_plan
success 필드 존재
monthly_plan 필드 존재
성공 결과이면 monthly_plan.days 길이 > 0
```

HTTP `200`이라고 해서 반드시 Solver가 성공한 결과만 의미하는지는 현재 API Contract를 기준으로 확인해야 합니다. 일부 Modeling 실패는 구조화된 Body로 반환될 수 있습니다.

### Smoke Test 성공

모든 검증이 통과하면 다음과 같은 완료 메시지가 출력됩니다.

```text
Modeling API HTTP smoke test completed successfully.
```

<br>

## 18. Docker 통합 검증

Docker 통합 테스트는 다음 요소를 함께 확인합니다.

```text
Docker Image Build
Container 실행
Uvicorn 기동
환경 변수 주입
Port Mapping
Health Check
Metrics Endpoint
API Key
HTTP Request
```

### Container 실행

```bash
MODELING_API_KEY=local-secret-key \
docker compose \
  -f docker-compose.modeling.yml \
  up \
  --build \
  -d
```

### 상태 확인

```bash
docker compose \
  -f docker-compose.modeling.yml \
  ps
```

### Health 확인

```bash
curl -fsS \
  http://127.0.0.1:8001/health \
  | python -m json.tool
```

### Metrics 확인

```bash
curl -fsS \
  -H "X-API-Key: local-secret-key" \
  http://127.0.0.1:8001/metrics
```

### Smoke Test

```bash
python \
  modeling/experiments/contract/run_modeling_api_http_smoke.py \
  --base-url http://127.0.0.1:8001 \
  --api-key local-secret-key
```

### Log 확인

```bash
docker compose \
  -f docker-compose.modeling.yml \
  logs \
  --tail=200 \
  modeling-api
```

### 종료

```bash
docker compose \
  -f docker-compose.modeling.yml \
  down
```

Docker 통합 검증은 Container와 HTTP 연결을 확인하지만, 배포 환경의 HTTPS 인증서, Security Group과 실제 운영 Reverse Proxy 전체를 검증하는 것은 아닙니다.

<br>

## 19. CI 테스트 흐름

관련 Workflow:

```text
.github/workflows/modeling-docker-build.yml
```

실제 CI 단계는 Workflow 파일 변경에 따라 달라질 수 있으므로 다음 명령으로 확인합니다.

```bash
sed -n '1,320p' \
  .github/workflows/modeling-docker-build.yml
```

대표적인 흐름:

```text
1. Python 환경 구성
2. RAG 오류 상태 Mapping 검증
3. API Request Validation Pytest
4. API Metrics Pytest
5. Docker Image Build
6. Container 실행
7. /health 확인
8. /metrics 확인
9. HTTP Smoke Test
10. Container 종료
```

### RAG 오류 Mapping

```bash
PYTHONPATH=modeling \
python \
  modeling/tests/api/test_modeling_api_rag_error_status.py
```

### API Pytest

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  -q \
  -p no:cacheprovider \
  modeling/tests/api/test_modeling_api_request_validation.py \
  modeling/tests/api/test_modeling_api_metrics.py
```

### Container Health

```text
http://localhost:8001/health
```

응답 가능 상태가 될 때까지 반복 확인할 수 있습니다.

### HTTP Smoke

```text
modeling/experiments/contract/run_modeling_api_http_smoke.py
```

실제 Container를 대상으로 Network 수준의 검증을 수행합니다.

### 현재 CI 범위 주의

Workflow에서 일부 API 테스트만 선택 실행한다면 다음 범주는 자동 검증에서 빠질 수 있습니다.

```text
contract
optimizer
persona
profile
rag
recommendation
plan
```

전체 `modeling/tests` 실행을 CI에 추가할지 검토할 수 있습니다.

```bash
ENV=prod \
MODELING_API_KEY=ci-secret-key \
PYTHONPATH=modeling \
python -m pytest \
  -q \
  -p no:cacheprovider \
  modeling/tests
```

<table style="background-color:#FFF1E6; border-left:6px solid #E67E22; padding:12px; width:100%;">
  <tr>
    <td>
      <strong>⚠️ 로컬 통과와 CI 통과</strong><br>
      로컬에서 전체 테스트가 통과해도 CI Workflow가 일부 테스트만 실행한다면
      해당 테스트가 지속적으로 보호된다고 볼 수 없습니다.
      중요한 회귀 테스트는 실제 CI 실행 목록에 포함해야 합니다.
    </td>
  </tr>
</table>

<br>

## 20. Pytest와 Experiment의 차이

### Pytest

목적:

```text
함수 동작
경계값
응답 계약
오류 매핑
회귀 방지
```

특징:

```text
빠른 실행
결과가 결정적이어야 함
네트워크 의존성 최소화
작은 Fixture 사용
Pass / Fail 중심
```

대표 검증:

```text
API가 422를 반환하는가
RAG Timeout이 504로 매핑되는가
selected_menu가 Mapping 이후 유지되는가
alternative_menus에서 중복 ID가 제거되는가
실패 응답 Contract가 유지되는가
```

### Experiment Validation

목적:

```text
추천 품질
시나리오별 안정성
Optimizer 성능
정책 비교
가중치 튜닝
```

특징:

```text
실제 또는 Snapshot 후보 사용
실행 시간이 김
JSON / CSV Artifact 생성
Pass / Warning / Fail 분석
여러 지표를 함께 비교
```

대표 검증:

```text
15개 시나리오에서 Solver가 성공하는가
중복률이 정책 목표 범위에 있는가
Runtime p95가 허용 범위인가
RAG 품질 이슈가 결과에 미치는 영향은 무엇인가
정책 변경 전후 Summary가 어떻게 달라지는가
```

### 역할 관계

```text
Pytest 통과
≠ 추천 품질 보장

Experiment 성공
≠ API Contract 안정성 보장

HTTP Smoke 통과
≠ 모든 Solver Constraint 검증

전체 품질 확보
= Pytest + Contract + Smoke + Experiment
```

<br>

## 21. Experiment Validation 도구

실제 파일 목록은 다음 명령으로 확인합니다.

```bash
find modeling/experiments \
  -type f \
  -name '*.py' \
  | sort
```

### Pipeline

대표 도구:

```text
run_final_validation_pipeline.py
run_optimizer_full_validation.py
run_optimizer_validation_pipeline.py
```

전체 시나리오 실행, 분석과 Summary 생성을 자동화합니다.

### Runner

대표 도구:

```text
run_baseline_mmr.py
run_least_cost_baseline.py
```

MMR 또는 최저가 Baseline을 생성해 Optimizer 결과와 비교합니다.

Baseline MMR은 OR-Tools 월간 경로의 실제 대표 메뉴 선택 방식과 동일하다는 뜻이 아니라, 비교 기준을 만들기 위한 실험 Runner입니다.

### Tuning

대표 도구:

```text
extract_optimizer_snapshots.py
grid_search_optimizer_tuning.py
replay_optimizer_policy.py
replay_optimizer_snapshots.py
```

동일 Snapshot에 서로 다른 Optimizer Policy를 적용해 결과를 비교합니다.

```text
Snapshot
→ 동일한 Profile과 Candidate 입력 보존

Replay
→ 외부 RAG를 다시 호출하지 않고 정책 재실행

Grid Search
→ 여러 가중치 조합 비교

Policy Replay
→ 기존 정책과 후보 정책의 결과 비교
```

### Analysis

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

실험 결과에서 비용, 난이도, 중복, RAG 품질과 Validation 상태를 추출합니다.

### Contract 도구

대표 도구:

```text
run_backend_contract_validation.py
run_modeling_api_http_smoke.py
run_modeling_service_contract_smoke.py
validate_backend_contract_requests.py
validate_backend_contract_responses.py
analyze_shopping_ingredient_coverage.py
```

Backend 요청·응답 구조와 장보기 재료 Coverage를 검증합니다.

### Experiment Artifact

대표 결과:

```text
시나리오별 실행 결과 JSON
Validation Summary
정책 비교 Summary
Runtime 통계
Candidate와 선택 메뉴 통계
RAG 품질 진단
```

Artifact는 실행 결과이므로 일반 Unit Test Fixture와 구분해 관리합니다.

<br>

## 22. 테스트 실패 해석

### Import Error

예시:

```text
ModuleNotFoundError: No module named 'services'
```

원인:

```text
PYTHONPATH=modeling 누락
프로젝트 루트가 아닌 위치에서 실행
가상환경 비활성화
잘못된 Import 경로
```

해결:

```bash
source .venv/bin/activate

PYTHONPATH=modeling \
python -m pytest \
  modeling/tests \
  -q
```

### HTTP 401

확인 항목:

```text
ENV 값
MODELING_API_KEY 값
X-API-Key Header
TestClient가 참조하는 server 전역 변수
Monkeypatch 적용 위치
```

### HTTP 422

응답 Body의 `detail`에서 다음을 확인합니다.

```text
필드 누락
잘못된 Literal
숫자 범위
허용 목록
List 중복
추가 또는 잘못된 중첩 구조
```

### HTTP 502

```text
RAG 연결 실패
RAG HTTP 오류
RAG 요청 오류
Upstream 응답 파싱 오류
```

### HTTP 504

```text
RAG Read Timeout
외부 Service 응답 지연
Network 지연
Timeout 설정 부족
```

### Metrics Count 불일치

Prometheus Counter는 Process 또는 Registry 상태를 유지합니다.

테스트에서 Metric 값을 초기화하거나 테스트 시작 전 기준값을 저장하지 않으면 이전 테스트의 값이 남아 있을 수 있습니다.

확인 항목:

```text
독립 Registry 사용 여부
테스트 실행 순서 의존성
기준값 이전·이후 비교 여부
동일 App Instance 재사용 여부
```

### Optimizer Mapping 테스트 실패

확인 항목:

```text
OR-Tools selected item이 selected_menu로 유지되는가
alternative_menus에서 selected_menu ID가 제거되는가
대체 메뉴 ID가 중복되는가
추천 후보가 충분한가
MMR 입력 필드가 존재하는가
```

### Smoke Test Monthly 실패

```text
200
→ Body Contract와 success 상태 확인

401
→ Key 설정 확인

422
→ Fixture Schema 확인

502
→ RAG Upstream 확인

504
→ RAG Timeout과 제한 시간 확인

500
→ Server Log와 Stack Trace 확인

Connection Refused
→ Container, Port Mapping과 Health 확인
```

### Experiment Validation 실패

```text
Solver 실패
→ 후보 수, 예산 가능성, Constraint 확인

Validation Fail
→ 실제 식단 품질 실패인지 Threshold·Score Source 불일치인지 구분

Warning 증가
→ 중복률, 후보 풀 여유도와 Style 기준 확인

Runtime 증가
→ Candidate 수, Solver 제한 시간과 Retry 횟수 확인
```

<br>

## 23. 테스트 작성 규칙

### 테스트 이름

```text
test_<대상>_<조건>_<기대결과>
```

예시:

```python
def test_rag_timeout_maps_to_504():
    ...
```

### Arrange · Act · Assert

```python
# Arrange
payload = read_valid_monthly_request()

# Act
response = client.post(
    "/monthly-plan",
    json=payload,
)

# Assert
assert response.status_code == 422
```

### 하나의 테스트는 하나의 핵심 실패 원인

한 테스트에서 너무 많은 정책을 함께 검증하면 실패 원인을 파악하기 어렵습니다.

```text
권장
→ 예산 Constraint 테스트
→ 반복 Constraint 테스트
→ selected_menu Mapping 테스트
→ alternative_menus 중복 테스트

비권장
→ 하나의 테스트에서 전체 월간 Pipeline의 모든 조건 검증
```

### 외부 의존성 격리

단위·API 테스트에서는 실제 RAG 호출을 피합니다.

```text
monkeypatch
fake function
고정 Fixture
Snapshot
```

실제 Network는 HTTP Smoke Test에서 검증합니다.

### 명확한 Assertion

가능하면 다음을 함께 확인합니다.

```text
HTTP Status
Response Field
Service 전달 Payload
Failure Reason
Solver Status
List 길이
대표 메뉴 유지 여부
중복 여부
예산 합계
```

### OR-Tools 경로와 비-OR-Tools 경로 구분

두 경로의 대표 메뉴 선택 책임이 다르므로 테스트도 구분해야 합니다.

```text
OR-Tools 경로
→ Solver selected_menu 유지
→ MMR은 alternative_menus 구성

비-OR-Tools 경로
→ MMR과 Style Priority가 selected_menu 선택에 사용될 수 있음
→ MMR이 alternative_menus도 구성
```

테스트 이름과 Fixture에서 어느 경로를 검증하는지 명확하게 표시합니다.

### 테스트용 Secret

실제 운영 Secret을 사용하지 않습니다.

```text
ci-secret-key
metrics-test-key
local-secret-key
```

### Artifact 생성 금지

Pytest는 Repository에 대형 JSON 결과를 생성하지 않도록 합니다.

결과 파일이 필요한 검증은 Experiment 영역에서 수행합니다.

### 시간과 Randomness 통제

테스트 결과가 실행마다 달라지지 않도록 다음 값을 고정합니다.

```text
Random Seed
현재 시간
외부 응답
Solver 입력
환경 변수
```

<br>

## 24. 현재 테스트 공백

현재 전용 테스트가 없거나 보강이 필요한 영역은 실제 `modeling/tests`와 `pytest --collect-only` 결과를 기준으로 확인합니다.

### Profile

```text
목표별 Weight 계산
복수 목표 평균과 재정규화
한 끼 예산 환산
권장 칼로리 미입력 처리
Cooking Skill과 max_difficulty Mapping
Diversity Level Mapping
period_days 기본값
```

### RAG Mapper

```text
가격 Mapping
사용량 단위 변환
RAG estimated_cost Fallback
영양소 누락
재료군 Mapping
Quality Score
Quality Penalty 입력
Nutrition Outlier
Mapping Diagnostics
중복 후보 병합
```

### Recommendation

```text
각 Score 공식
가중합 base_final_score
Style Soft Constraint
Quality Penalty
최종 final_score
정렬 Tie Breaker
난이도 Score Source
다양성 감점
```

### Optimizer Candidate Builder

```text
Final Score 상위 후보 선별
저비용 후보 보충
중복 후보 제거
후보 제한 개수
후보 부족 처리
MMR 점수가 후보 선별에 사용되지 않음
```

### MMR 및 Plan

```text
Lambda 경계값
유사도 경계값
메뉴명 Prefix 정규화
Jaccard Similarity
최근 Day Window
사용 횟수 Penalty
OR-Tools selected_menu 유지
비-OR-Tools 대표 메뉴 선택
alternative_menus 조건 완화
대체 메뉴 중복 방지
Plan Summary
Backend Payload 경량화
```

### OR-Tools

```text
Slot당 정확히 한 메뉴
월 예산 Constraint
최대 반복 Constraint
Linear Repeat Penalty
Quadratic Repeat Penalty
Protein Bonus Cap
Difficulty Bonus
Nutrition Outlier Penalty
OPTIMAL / FEASIBLE 처리
UNKNOWN / INFEASIBLE 처리
후보 부족 사전 검사
예산 불가능 사전 검사
Retry 후보 확장
```

### Validation

```text
Style별 Pass / Warning / Fail 경계
Secondary Warning
Duplicate Rate
Difficulty Feasibility
Budget Feasibility
Recommendation Hint
selected_menu 기준 Summary와 Validation
alternative_menus 제외 확인
```

### 통합 경로

```text
Profile
→ RAG Mapping
→ Recommendation
→ Optimizer Candidate Builder
→ OR-Tools
→ Plan Mapping
→ MMR Alternatives
→ Summary / Validation
```

<br>

## 25. 권장 보강 순서

### 1순위: OR-Tools Hard Constraint

잘못된 결과가 사용자 예산과 식단 개수에 직접 영향을 주므로 가장 먼저 보강합니다.

```text
월 예산 초과 금지
Slot 누락 금지
한 Slot에 복수 메뉴 선택 금지
반복 상한 초과 금지
```

### 2순위: Optimizer 결과와 Plan Mapping

OR-Tools가 선택한 대표 메뉴가 후처리에서 변경되지 않는지 고정합니다.

```text
selected item
→ selected_menu 유지

MMR
→ alternative_menus만 구성
```

### 3순위: Recommendation Score

가중치 또는 필드 Source 변경 시 전체 결과가 달라지므로 Score별 단위 테스트가 필요합니다.

```text
budget_score
nutrition_score
preference_score
difficulty_score
diversity_score
base_final_score
style_soft_constraint_score
total_quality_penalty
final_score
```

### 4순위: Optimizer Candidate Builder

OR-Tools에 어떤 후보가 전달되는지 검증합니다.

```text
Final Score 상위 후보
저비용 후보
중복 제거
후보 제한
MMR 미사용
```

### 5순위: MMR·유사도 경계

```text
Lambda 경계
유사도 Threshold
사용 횟수 Penalty
최근 Day Window
selected_menu 제외
alternative_menus 중복 방지
```

### 6순위: Plan Summary와 Payload

Backend 계약과 Validation 입력에 사용되므로 계산 필드와 제거 필드를 고정합니다.

```text
Summary는 selected_menu 기준
alternative_menus는 초기 Summary에서 제외
Backend Payload 필드 고정
```

### 7순위: Style Validation Threshold

Threshold 변경이 Pass·Warning·Fail 결과에 미치는 영향을 명시적으로 검증합니다.

### 8순위: Optimizer Retry

추가 RAG 후보 요청, Mapping, 병합, Recommendation 재계산과 재실행을 Mock 기반 통합 테스트로 검증합니다.

```text
초기 Optimizer 실패
→ 후보 부족 진단
→ 추가 RAG 요청
→ Mapping
→ 후보 병합
→ Recommendation 재계산
→ Optimizer Candidate 재구성
→ OR-Tools 재실행
```

### 9순위: 전체 Pipeline 회귀 테스트

작은 Snapshot Fixture를 사용해 전체 연결을 고정합니다.

```text
Profile
→ RAG
→ Recommendation
→ Optimizer
→ Plan
→ Validation
```

<br>

## 26. 관련 문서

### Repository 문서

- [`../README.md`](../README.md)  
  Modeling 전체 아키텍처, 실행과 검증 방법

- [`../api/README.md`](../api/README.md)  
  FastAPI Endpoint, 인증, 오류 처리와 Prometheus Metrics

- [`../services/profile/README.md`](../services/profile/README.md)
  사용자 Profile 정규화와 계산용 파생값

- [`../services/rag/README.md`](../services/rag/README.md)
  RAG 요청, 응답 Mapping, 품질 진단과 Fallback

- [`../services/recommendation/README.md`](../services/recommendation/README.md)
  후보별 Score와 `final_score` 계산

- [`../services/persona/README.md`](../services/persona/README.md)  
  Persona Profile Build 로직

- [`../services/optimizer/README.md`](../services/optimizer/README.md)  
  OR-Tools Constraint, Objective와 Retry 정책

- [`../services/plan/README.md`](../services/plan/README.md)  
  대표 메뉴 Mapping, MMR 대체 메뉴, Plan Summary와 Payload

- [`../experiments/README.md`](../experiments/README.md)  
  Scenario, Snapshot, Replay, Pipeline과 Artifact 관리

- [`../deploy/README.md`](../deploy/README.md)  
  Docker Build, CI, EC2 배포와 운영 검증

### Contract 및 운영 가이드

- [`../docs/modeling_serving_guide.md`](../docs/modeling_serving_guide.md)  
  로컬·Docker Modeling API 실행 및 Smoke Test

- [`../docs/backend_modeling_api_client_guide.md`](../docs/backend_modeling_api_client_guide.md)  
  Backend 요청 Header, Timeout과 API 계약

- [`../docs/modeling_serving_pr_checklist.md`](../docs/modeling_serving_pr_checklist.md)  
  서빙 코드 PR 전 확인 항목