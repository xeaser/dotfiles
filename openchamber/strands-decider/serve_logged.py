"""Run the strands-decider server with a JSONL line per /v1/systemone call.

Each line records the request (state, questions and their options) and the
response (answers, probabilities, confidence, latency). The log goes to
$STRANDS_HOME/systemone.jsonl; the upstream stdout log is unchanged.

Environment:
  STRANDS_HOME  runtime dir (venv, model cache, logs). Default /Volumes/Work/Model/strands
  PORT          listen port on 127.0.0.1. Default 38417
  CHECKPOINT    Hugging Face checkpoint to serve
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
LOG_PATH = os.path.join(STRANDS_HOME, "systemone.jsonl")

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
    with open(LOG_PATH, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, ensure_ascii=False) + "\n")
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
