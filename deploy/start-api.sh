#!/bin/bash
# Start script for FastAPI application
# This is called by systemd service

cd /opt/leaseledger
source venv/bin/activate

# Set environment variables
export DB_DRIVER=${DB_DRIVER:-sqlite}
export DB_PATH=${DB_PATH:-/opt/leaseledger/data/leaseledger.db}
export PYTHONUNBUFFERED=1

# Start uvicorn
exec uvicorn app.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --workers 4 \
    --log-level info \
    --access-log

