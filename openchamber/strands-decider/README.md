# strands-decider (OpenChamber classifier)

A local classification model for OpenChamber's **Auto** model routing, so the
"which category is this prompt?" decision never leaves the laptop.

It runs [Strands Decider 2B](https://github.com/strands-labs/strands-decider)
(`StrandsAgents/strands-decider-2B-qwen3.5-v1-2610`, Apache-2.0) through MLX and
serves the System One API (`POST /v1/systemone`) on `127.0.0.1:38417`.
LM Studio and Ollama cannot load it: it has a custom pointer head instead of an
LM head, so it needs its own server.

Microsoft-Decision-1 was considered and ruled out: the weights are closed
(Foundry / OpenRouter only).

## Layout

Source (this repo) and runtime (not in git) are split:

| What | Where |
|---|---|
| Server wrapper, launcher, LaunchAgent plist, setup script | `openchamber/strands-decider/` |
| Venv, upstream clone, model cache, logs | `/Volumes/Work/Model/strands` (`$STRANDS_HOME`) |
| LaunchAgent (symlink to the plist here) | `~/Library/LaunchAgents/dev.openchamber.strands-decider-classifier.plist` |

Files here:

- `serve_logged.py`: wraps the upstream `create_app` and appends one JSON line per
  classification to `$STRANDS_HOME/systemone.jsonl`. Warms the model before listening.
- `run-strands`: LaunchAgent entry point (sets `HF_HOME`, execs the venv python).
- `dev.openchamber.strands-decider-classifier.plist`: label is chosen to be
  recognisable under System Settings → General → Login Items & Extensions.
- `setup.sh`: idempotent install (clone, venv, model download, link plist, load agent).

## Setup

```bash
~/dotfiles/openchamber/strands-decider/setup.sh
```

Needs `uv` and `git`, the `/Volumes/Work` volume mounted, and network for the
first model download (~4.5 GB into `$STRANDS_HOME/hf`).

Then in OpenChamber → **Settings → Providers → Classification providers**,
choose **Custom endpoint**:

| Field | Value |
|---|---|
| Endpoint URL | `http://127.0.0.1:38417/v1/systemone` |
| Model | `strands-decider-2B-qwen3.5-v1-2610` |
| API key | empty |

Press **Test**; it should answer in about 100 ms. Then **Settings → Routing**:
enable Auto mode, pick a fallback model, and give each category its own model.
Without a per-category model, every prompt goes to the fallback.

## Port

`38417` was picked to avoid common dev ports (8000, 3000, 8080) and to sit below
macOS's ephemeral range (49152+). To change it, edit `PORT` in the plist and the
endpoint URL in OpenChamber, then reload the agent.

## Operate

```bash
LABEL=dev.openchamber.strands-decider-classifier
launchctl print gui/$(id -u)/$LABEL | grep -E "state|pid"     # status
launchctl kickstart -k gui/$(id -u)/$LABEL                    # restart
launchctl bootout gui/$(id -u)/$LABEL                         # stop
curl -s http://127.0.0.1:38417/health                         # health
tail -f /Volumes/Work/Model/strands/server.log                # server log
```

If the volume is not mounted at login the launcher exits and launchd retries
every 30 s until it appears.

## Reading the log

`$STRANDS_HOME/systemone.jsonl` has `ts`, `elapsed_ms`, `request` (state and
questions) and `response` (choice, per-option probabilities, confidence):

```bash
python3 - <<'EOF'
import json
for l in open("/Volumes/Work/Model/strands/systemone.jsonl"):
    r = json.loads(l)
    st = r["request"].get("state", "")
    st = st if isinstance(st, str) else json.dumps(st)
    ans = {q: (a.get("choice"), a.get("confidence")) for q, a in r["response"].get("answers", {}).items()}
    print(r["ts"][11:19], r["elapsed_ms"], repr(st[:90]), ans)
EOF
```

The file contains excerpts of your conversations. It stays local; delete it when
you are done debugging.

## Behaviour to know

- OpenChamber waits 4 s and uses the fallback model below 60% confidence or on any
  failure, so a down classifier degrades to the fallback rather than breaking chat.
- It sends conversation history in `state`, so short follow-ups ("check the logs")
  score low and fall back. Standalone prompts classify cleanly.
- The `Hard` category uses `Claude Opus 5.5 (Global)` because the US variant was not
  listed for the Bedrock provider.

## Related

- `README.md` (this folder's parent): OpenChamber desktop app and remote access
