"""Run the strands-decider server and log every /v1/systemone call.

$STRANDS_HOME/systemone.json is one valid JSON array, newest entry first (index 0).
Each entry records the request (state, questions and their options) and the
response (answers, probabilities, confidence, latency). The file is rewritten
atomically on every call and capped at MAX_LOG_ENTRIES; the upstream stdout log
is unchanged.

Environment:
  STRANDS_HOME     runtime dir (venv, model cache, logs). Default /Volumes/Work/Model/strands
  PORT             listen port on 127.0.0.1. Default 38417
  CHECKPOINT       Hugging Face checkpoint to serve
  MAX_LOG_ENTRIES  entries kept in the log. Default 2000
"""

import json
import os
import sys
import time
from datetime import datetime, timezone

import uvicorn
from starlette.requests import Request
from starlette.responses import Response

from strands_decider.schema import SystemOneRequest
from strands_decider.server import create_app, get_engine

STRANDS_HOME = os.environ.get("STRANDS_HOME", "/Volumes/Work/Model/strands")
CHECKPOINT = os.environ.get("CHECKPOINT", "StrandsAgents/strands-decider-2B-qwen3.5-v1-2610")
HOST = "127.0.0.1"
PORT = int(os.environ.get("PORT", "38417"))
MAX_LOG_ENTRIES = int(os.environ.get("MAX_LOG_ENTRIES", "2000"))
LOG_PATH = os.path.join(STRANDS_HOME, "systemone.json")


def _load_log() -> list:
    try:
        with open(LOG_PATH, encoding="utf-8") as fh:
            data = json.load(fh)
        return data if isinstance(data, list) else []
    except (FileNotFoundError, json.JSONDecodeError):
        return []


_entries: list = _load_log()


def _write_log(record: dict) -> None:
    _entries.insert(0, record)
    del _entries[MAX_LOG_ENTRIES:]
    tmp = LOG_PATH + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(_entries, fh, ensure_ascii=False, indent=2)
    os.replace(tmp, LOG_PATH)

app = create_app(CHECKPOINT, device="mlx")


@app.middleware("http")
async def log_systemone(request: Request, call_next):
    if request.url.path != "/v1/systemone":
        return await call_next(request)

    body = await request.body()

    async def receive():
        return {"type": "http.request", "body": body, "more_body": False}

    request._receive = receive

    started = time.perf_counter()
    response = await call_next(request)
    raw = b"".join([chunk async for chunk in response.body_iterator])
    elapsed_ms = round((time.perf_counter() - started) * 1000, 2)

    try:
        req_json = json.loads(body or b"{}")
    except json.JSONDecodeError:
        req_json = {"raw": body.decode("utf-8", "replace")}
    try:
        resp_json = json.loads(raw or b"{}")
    except json.JSONDecodeError:
        resp_json = {"raw": raw.decode("utf-8", "replace")}

    record = {
        "ts": datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds"),
        "status": response.status_code,
        "elapsed_ms": elapsed_ms,
        "request": req_json,
        "response": resp_json,
    }
    _write_log(record)
    print(
        f"[systemone] {record['ts']} status={response.status_code} "
        f"elapsed_ms={elapsed_ms} questions={list(req_json.get('questions', {}))}",
        file=sys.stderr,
        flush=True,
    )

    headers = {k: v for k, v in response.headers.items() if k.lower() != "content-length"}
    return Response(
        content=raw,
        status_code=response.status_code,
        headers=headers,
        media_type=response.media_type,
    )


def warm_up() -> None:
    get_engine().evaluate(
        SystemOneRequest.model_validate(
            {
                "state": "warm up",
                "questions": {
                    "q": {
                        "type": "choice",
                        "instructions": "Pick one.",
                        "criteria": {"a": "first", "b": "second"},
                    }
                },
            }
        )
    )


if __name__ == "__main__":
    warm_up()
    uvicorn.run(app, host=HOST, port=PORT, workers=1)
