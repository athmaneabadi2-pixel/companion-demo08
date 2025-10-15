@echo off
setlocal
chcp 65001 >nul
set "BASE=http://127.0.0.1:5000"
set "PYTMP=%TEMP%\_smoke_cf.py"

echo [Smoke] Vérif JSON /health et /internal/send via Python...

REM -- (re)crée le script Python LIGNE PAR LIGNE (pas de parenthèses, pas de piège) --
del "%PYTMP%" >nul 2>&1
> "%PYTMP%"  echo import json, os, urllib.request
>> "%PYTMP%" echo base = os.environ.get("BASE","http://127.0.0.1:5000")
>> "%PYTMP%" echo # /health
>> "%PYTMP%" echo h = json.loads(urllib.request.urlopen(base + "/health", timeout=5).read().decode("utf-8"))
>> "%PYTMP%" echo assert str(h.get("status","")).lower() == "ok", "health not ok"
>> "%PYTMP%" echo # /internal/send
>> "%PYTMP%" echo payload = b'{"text":"Salut"}'
>> "%PYTMP%" echo req = urllib.request.Request(
>> "%PYTMP%" echo ^    base + "/internal/send",
>> "%PYTMP%" echo ^    data=payload,
>> "%PYTMP%" echo ^    headers={"Content-Type":"application/json","X-Token":"dev-123"},
>> "%PYTMP%" echo ^    method="POST"
>> "%PYTMP%" echo )
>> "%PYTMP%" echo s = json.loads(urllib.request.urlopen(req, timeout=10).read().decode("utf-8"))
>> "%PYTMP%" echo assert bool(s.get("ok")) is True, "internal send not ok"
>> "%PYTMP%" echo print("[OK] Smoke test passe.")

REM -- Exécute le script Python --
python "%PYTMP%" || (echo [X] Smoke test KO & del "%PYTMP%" >nul 2>&1 & exit /b 1)
del "%PYTMP%" >nul 2>&1
exit /b 0
