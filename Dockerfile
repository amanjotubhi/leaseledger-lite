FROM python:3.11-slim
RUN apt-get update && apt-get install -y build-essential libaio1 curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
ENV DB_PATH=/app/app/leaseledger.db
ENV DB_DRIVER=sqlite
EXPOSE 8000
CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8000"]


