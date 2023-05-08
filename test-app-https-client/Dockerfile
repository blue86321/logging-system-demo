FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/test-app-https-client-0.0.1-SNAPSHOT.jar app.jar
COPY opentelemetry-javaagent.jar opentelemetry-javaagent.jar

ENV OTEL_SERVICE_NAME=test-app-https-client
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_METRICS_EXPORTER=none

EXPOSE 8080

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-Dio.opentelemetry.javaagent.slf4j.simpleLogger.defaultLogLevel=off", "-jar", "app.jar"]
