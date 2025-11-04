Param([string]$OraclePassword = 'oracle')
Write-Host 'Starting Oracle and API with docker compose' -ForegroundColor Cyan
docker compose up -d db
Write-Host 'Waiting for Oracle init…'
Start-Sleep -Seconds 45
$schema = Get-Content -Raw '.\db\oracle\schema_oracle.sql'
$seed   = Get-Content -Raw '.\db\oracle\seed_oracle.sql'
$script = $schema + "`n" + $seed
$bytes  = [System.Text.Encoding]::UTF8.GetBytes($script)
$stream = [System.IO.MemoryStream]::new($bytes)
docker exec -i $(docker ps -q --filter "ancestor=gvenzl/oracle-free:23.5") bash -lc "sqlplus -s system/$OraclePassword@localhost/FREEPDB1" < $stream
docker compose up -d api
Write-Host 'API at http://localhost:8000  health at /health' -ForegroundColor Green


