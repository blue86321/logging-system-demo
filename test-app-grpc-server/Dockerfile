FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt

COPY . .

ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_METRICS_EXPORTER=none
ENV OTEL_SERVICE_NAME=my-grpc-server
ENV OTEL_PYTHON_LOG_CORRELATION=true
ENV OTEL_LOGS_EXPORTER=console

EXPOSE 50051

CMD ["opentelemetry-instrument", "python", "my-grpc-server.py"]
