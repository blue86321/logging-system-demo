FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the Maven project files to the container
COPY pom.xml .
COPY src ./src
COPY .mvn ./.mvn
COPY mvnw ./mvnw

# Build the Maven project
RUN ./mvnw package -DskipTests
RUN mv target/test-app-https-client-0.0.1-SNAPSHOT.jar app.jar

# Download opentelemetry-javaagent.jar
RUN apt-get update && apt-get install -y curl
RUN curl -LJO https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

ENV OTEL_SERVICE_NAME=test-app-https-client
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_METRICS_EXPORTER=none
# ENV OTEL_LOGS_EXPORTER=otlp

EXPOSE 8080

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-Dio.opentelemetry.javaagent.slf4j.simpleLogger.defaultLogLevel=off", "-jar", "app.jar"]
