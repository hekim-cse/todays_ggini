from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from api import server
from api.metrics import (
    HTTP_REQUEST_DURATION_SECONDS,
    HTTP_REQUESTS_IN_PROGRESS,
    HTTP_REQUESTS_TOTAL,
)


client = TestClient(server.app)


@pytest.fixture(autouse=True)
def reset_metrics() -> None:
    """
    각 테스트가 이전 테스트의 Prometheus 시계열 값에 의존하지 않도록
    전용 Collector의 내부 상태를 초기화한다.
    """

    for metric in (
        HTTP_REQUESTS_TOTAL,
        HTTP_REQUEST_DURATION_SECONDS,
        HTTP_REQUESTS_IN_PROGRESS,
    ):
        metric.clear()



def test_metrics_requires_api_key_in_prod(monkeypatch) -> None:
    monkeypatch.setattr(server, "ENV", "prod")
    monkeypatch.setattr(server, "MODELING_API_KEY", "metrics-test-key")

    response = client.get("/metrics")

    assert response.status_code == 401
    assert response.json() == {
        "detail": "Invalid or missing API key.",
    }


def test_metrics_returns_prometheus_content(monkeypatch) -> None:
    monkeypatch.setattr(server, "ENV", "prod")
    monkeypatch.setattr(server, "MODELING_API_KEY", "metrics-test-key")

    response = client.get(
        "/metrics",
        headers={
            "X-API-Key": "metrics-test-key",
        },
    )

    assert response.status_code == 200
    assert response.headers["content-type"].startswith(
        "text/plain"
    )

    assert "modeling_http_requests_total" in response.text
    assert "modeling_http_request_duration_seconds" in response.text
    assert "modeling_http_requests_in_progress" in response.text


def test_business_request_is_recorded_in_metrics(monkeypatch) -> None:
    monkeypatch.setattr(server, "ENV", "prod")
    monkeypatch.setattr(server, "MODELING_API_KEY", "metrics-test-key")

    response = client.post(
        "/monthly-plan",
        json={},
    )

    assert response.status_code == 422

    metrics_response = client.get(
        "/metrics",
        headers={
            "X-API-Key": "metrics-test-key",
        },
    )

    assert metrics_response.status_code == 200

    expected_labels = (
        'method="POST",path="/monthly-plan",status_code="422"'
    )

    assert expected_labels in metrics_response.text


def test_unknown_paths_use_bounded_label(monkeypatch) -> None:
    monkeypatch.setattr(server, "ENV", "prod")
    monkeypatch.setattr(server, "MODELING_API_KEY", "metrics-test-key")

    response = client.get("/arbitrary-user-controlled-path")

    assert response.status_code == 404

    metrics_response = client.get(
        "/metrics",
        headers={
            "X-API-Key": "metrics-test-key",
        },
    )

    assert metrics_response.status_code == 200
    assert 'path="/unmatched"' in metrics_response.text
    assert "/arbitrary-user-controlled-path" not in metrics_response.text


def test_health_and_metrics_requests_are_not_recorded(monkeypatch) -> None:
    monkeypatch.setattr(server, "ENV", "prod")
    monkeypatch.setattr(server, "MODELING_API_KEY", "metrics-test-key")

    health_response = client.get("/health")
    metrics_response = client.get(
        "/metrics",
        headers={
            "X-API-Key": "metrics-test-key",
        },
    )

    assert health_response.status_code == 200
    assert metrics_response.status_code == 200

    assert 'path="/health"' not in metrics_response.text
    assert 'path="/metrics"' not in metrics_response.text
