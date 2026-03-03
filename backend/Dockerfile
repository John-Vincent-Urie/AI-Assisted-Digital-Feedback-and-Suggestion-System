# syntax=docker/dockerfile:1.7
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN --network=host pip install --no-cache-dir --retries 10 --timeout 120 -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
