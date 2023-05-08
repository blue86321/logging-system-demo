
# AWS OpenSearch Trace Analytics

- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and output to `stdout` directly
- `test-app-https-client` is a Java Spring Boot web application.
- `test-app-grpc-server` is a GRPC server written in Python.

## Process
- Visiting an url to trigger `test-app-https-client` and `test-app-grpc-server` .
- Apps trace data is instrumented by OpenTelemetry Auto-Instrumentation.
- Trace data is then collected by Jaeger Collector, and then send to OpenSearch.

## OpenSearch
- Go to AWS OpenSearch, create a OpenSearch domain (instance)
  - Development mode
    - 1 AZ
    - instance type: `t3.small.search`
    - Number of nodes: 1
  - Network
    - Public Access
  - Fine-grained access control
    - Create master user
      - username: `admin`
      - password: `Admin_123`
  - Access policy
    - Configure domain level access policy
      - `IAM ARN`
      - `*`
      - `Allow`
- When new instance is ready (about 20 min), copy the `Domain endpoint`


## Docker
- Configure `ES_SERVER_URLS` in `docker-compose-aws-trace.yaml` with `Domain endpoint`
- Start docker

```shell
# Deploy container (Ctrl-C to exit)
docker-compose -f docker-compose-aws-trace.yaml up
# Delete all container
docker-compose down
```

## Visit
- Trigger apps behavior, visit [http://localhost:8080/hello/test/](http://localhost:8080/hello/test/)
- Go to AWS OpenSearch Dashboard -> left-side menu -> Observability -> Trace Analytics. You should see the trace data.
- If you think OpenSearch Dashboard is not ideal, you can try Jaeger UI on [http://localhost:16686/](http://localhost:16686/)


## Run Apps on Local Machine
- In previous section, apps is running on docker.
- If you want to run on your local machine instead of docker, or you want to custom code and run it on docker again, please follow the instructions below.

### Run Java HTTP Client on Local Machine
```shell
cd test-app-https-client
# Only for grpc protos
# mkdir src/main/proto
# cp -R ../proto src/main/
mvn -DGRPC_SERVER=test-app-grpc-server:50051 package
java \
  -javaagent:opentelemetry-javaagent.jar \
  -Dotel.service.name=test-app-https-client \
  -Dotel.traces.exporter=otlp \
  -Dotel.metrics.exporter=none \
  -Dio.opentelemetry.javaagent.slf4j.simpleLogger.defaultLogLevel=off \
  -DGRPC_SERVER=localhost:50051 \
  -jar target/test-app-https-client-0.0.1-SNAPSHOT.jar
```
- Note: To successfully collect trace data, you still need to launch docker, but comment the `test-app-https-client` part.

### Run Python GRPC Server on Local Machine
```shell
cd test-app-grpc-server
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# Only for grpc protos
# python -m grpc_tools.protoc -I../proto --python_out=. --pyi_out=. --grpc_python_out=. ../proto/hello.proto
opentelemetry-instrument \
    --traces_exporter otlp \
    --metrics_exporter none \
    --service_name my-grpc-server \
    --exporter_otlp_endpoint 0.0.0.0:4317 \
    python my-grpc-server.py

deactivate  # exit venv
rm -r venv  # delete venv
```
- Note: To successfully collect trace data, you still need to launch docker, but comment the `test-app-grpc-server` part.
