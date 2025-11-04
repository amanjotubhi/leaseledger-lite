Write-Host 'Running API with SQLite' -ForegroundColor Cyan
$env:DB_DRIVER = 'sqlite'
$env:DB_PATH = "$PWD\app\leaseledger.db"
python -m uvicorn app.main:app --reload


