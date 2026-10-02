# AGENTS.md

## Overview

- MoneyPrinterTurbo: AI short-video generator — prompt/script → LLM script + search terms → stock/AI materials → TTS + subtitles → final MP4. Python 3.11+ managed with **uv** (`pyproject.toml` is the primary manifest, `uv.lock` pins the environment, `requirements.txt` is legacy pip only). CI also tests 3.13.
- Three entrypoints share one pipeline in `app/services/task.py` (stages: script → terms → audio → subtitle → materials → video, selected via `--stop-at`):
  - `main.py` — FastAPI API server (`app.asgi:app`)
  - `webui/Main.py` — Streamlit UI
  - `cli.py` — headless argparse CLI; also powers `docs/skill/mpt_agent.py` (agent-facing Skill, invoked via subprocess). `docs/skill/` is production code — linted, tested, and included in coverage.

## Commands (run from repo root)

```powershell
uv sync --frozen                                                # install
uv run ruff check app cli.py main.py webui test docs/skill      # lint (CI runs ruff on 3.11 only)
uv run python -X utf8 -m pytest -q test                         # all tests
uv run python -X utf8 -m pytest -q test/services/test_video.py::TestVideoService::test_preprocess_video  # single test
uv run python main.py                                           # API server (default http://127.0.0.1:8080, port from config.toml listen_port)
.\webui.bat                                                     # WebUI on port 8501 (sh webui.sh on macOS/Linux; auto-falls back to 8501–8599)
uv run python cli.py --video-subject "..." --stop-at video      # CLI generation; cli.py --help for the full reference
```

CI order: `compileall` → `ruff` → `pytest` under branch coverage (`fail_under = 70`, sources: `app`, `cli`, `webui`, `main`, `docs/skill`), on Python 3.11 + 3.13 plus a separate Windows smoke job. New untested code can fail CI through the 70% coverage floor.

## Testing

- pytest collects both `unittest.TestCase` and pytest-style tests. Always pass `-X utf8` (Windows encoding issues).
- Integration tests calling external TTS/LLM providers are skipped unless `MPT_RUN_INTEGRATION_TESTS=1` and provider credentials are set.
- Redis-backed tests expect `MPT_TEST_REDIS_HOST` / `MPT_TEST_REDIS_PORT` / `MPT_TEST_REDIS_DB` (CI: Redis 7 service on 6379, db 15).
- Tests live in `test/` (see `test/README.md`): one domain per file, controller suites split as `test_controller_*.py`.

## Gotchas

- Run from repo root: config loads from `<repo-root>/config.toml` (gitignored; copied from `config.example.toml` on first run). Never commit `config.toml` or print its contents / API keys.
- `webui/Main.py` must add the repo root to `sys.path` before importing `app`; E402 is ignored for that file only (`pyproject.toml` per-file-ignores) — do not reorder those imports.
- Single-task and batch validation share constants in `cli.py`: new `video_source` values must go into `_CLI_VIDEO_SOURCES`, and the matching list in `docs/skill/mpt_agent.py` must stay aligned. Paid generation providers (wavespeed, volcengine_seedance, ofox, metaso_minimax, muapi) additionally require `--confirm-*-charge` flags and config support.
- CLI option precedence: explicit option > saved `[ui]` section in `config.toml` > built-in default. `VideoParams` field defaults read `config.ui` at import time; `cli.py` deliberately keeps its own defaults for robustness — don't unify them naively.
- MoviePy is v2 (`moviepy==2.2.1`); most online MoviePy examples show the incompatible v1 API.
- Code comments are predominantly Chinese — match that style. `CLAUDE.md` is gitignored on purpose.
- Docker: release images build via `docker compose -f docker-compose.release.yml up`; `docker-compose.claude.yml` (Claude Code subscription as LLM provider) requires `export CLAUDE_CODE_OAUTH_TOKEN="$(claude setup-token)"` first.
