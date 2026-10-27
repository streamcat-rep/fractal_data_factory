$root = Split-Path -Parent $PSScriptRoot
& "$root\.venv\Scripts\python.exe" -m pip install -r "$PSScriptRoot\requirements.txt" --quiet
& "$root\.venv\Scripts\python.exe" "$PSScriptRoot\app.py"
