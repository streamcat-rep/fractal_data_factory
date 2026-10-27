from __future__ import annotations

import os
import queue
import subprocess
import threading
from pathlib import Path

from dotenv import load_dotenv
from flask import Flask, Response, render_template_string, request

PROJECT_DIR = Path(__file__).resolve().parent.parent
VENV_DBT = PROJECT_DIR / ".venv" / "Scripts" / "dbt.exe"

load_dotenv(PROJECT_DIR / ".env")

app = Flask(__name__)

log_queue: "queue.Queue[str]" = queue.Queue()
state = {"running": False}
lock = threading.Lock()

PAGE = """
<!doctype html>
<title>dbt runner</title>
<style>
  body { font-family: system-ui, sans-serif; max-width: 760px; margin: 2rem auto; padding: 0 1rem; }
  input[type=text] { width: 100%; padding: .5rem; font-size: 1rem; box-sizing: border-box; }
  button { padding: .5rem 1.2rem; font-size: 1rem; margin-top: .5rem; cursor: pointer; }
  button:disabled { cursor: not-allowed; opacity: .5; }
  pre { background: #111; color: #eee; padding: 1rem; height: 420px; overflow-y: auto; border-radius: 6px; white-space: pre-wrap; }
  .running { color: #c77; font-weight: bold; }
</style>
<h1>dbt run</h1>
<form id="f">
  <label>--select (vac&iacute;o = todos los modelos; soporta tag:xxx)</label>
  <input type="text" name="select" id="select" placeholder="ej: tag:nightly, my_model, path:models/staging">
  <button type="submit" id="runbtn">Run</button>
</form>
<p id="status"></p>
<pre id="log"></pre>
<script>
const logEl = document.getElementById('log');
const statusEl = document.getElementById('status');
const runBtn = document.getElementById('runbtn');

function connectStream() {
  const es = new EventSource('/stream');
  es.onmessage = (e) => {
    if (e.data === '__DONE__') {
      statusEl.textContent = 'Terminado.';
      runBtn.disabled = false;
      es.close();
      return;
    }
    logEl.textContent += e.data + "\\n";
    logEl.scrollTop = logEl.scrollHeight;
  };
}

document.getElementById('f').addEventListener('submit', async (ev) => {
  ev.preventDefault();
  logEl.textContent = '';
  statusEl.textContent = 'Lanzando...';
  runBtn.disabled = true;
  const select = document.getElementById('select').value;
  const res = await fetch('/run', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({select})
  });
  if (!res.ok) {
    statusEl.textContent = await res.text();
    runBtn.disabled = false;
    return;
  }
  statusEl.innerHTML = '<span class="running">Corriendo...</span>';
  connectStream();
});
</script>
"""


def _run_dbt(select: str) -> None:
    cmd = [str(VENV_DBT), "run"]
    if select:
        cmd += ["--select", select]

    env = os.environ.copy()
    env["DBT_RUN_CACHE_DISABLED"] = "true"

    log_queue.put(f"$ {' '.join(cmd)}")
    process = subprocess.Popen(
        cmd,
        cwd=str(PROJECT_DIR),
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )
    assert process.stdout is not None
    for line in process.stdout:
        log_queue.put(line.rstrip())
    process.wait()
    log_queue.put(f"[exit code {process.returncode}]")
    log_queue.put("__DONE__")
    with lock:
        state["running"] = False


@app.route("/")
def index():
    return render_template_string(PAGE)


@app.route("/run", methods=["POST"])
def run():
    with lock:
        if state["running"]:
            return "Ya hay un dbt run en curso.", 409
        state["running"] = True

    select = (request.get_json(silent=True) or {}).get("select", "").strip()
    threading.Thread(target=_run_dbt, args=(select,), daemon=True).start()
    return "", 202


@app.route("/stream")
def stream():
    def gen():
        while True:
            line = log_queue.get()
            yield f"data: {line}\n\n"
            if line == "__DONE__":
                break

    return Response(gen(), mimetype="text/event-stream")


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5005, threaded=True)
