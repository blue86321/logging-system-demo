# Logging System Demo

## Overview
This demo is to show how to implement a logging system.
- **Demo1**: Fluent Bit simply collects loggings and output to **stdout**
- **Demo2**: Fluent Bit collects loggings and output to **Elasticsearch and Kibana**
- **Demo3**: Fluent Bit collects loggings and output to **AWS OpenSearch**
- **Trace Analytics**: traces demo and append `trace-id` and `span-id` to loggings by **OpenTelemetry**.
- **Frontend Logging**: Demo showing the logging process **Frontend -> Nginx -> Fluent Bit**

## Demo1 (stdout)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and prints on `stdout`

<img src="./imgs/StdoutDemoOverview.jpg" width="500"/>


```sh
# Deploy container (Ctrl-C to exit)
docker compose up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker compose down
```

<img src="./imgs/StdoutDemoResult.jpg" width="700"/>


## Demo2 (elasticsearch)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and sends to `elasticsearch`

<img src="./imgs/ElasticsearchDemoOverview.jpg" width="700"/>

```sh
# Deploy container (Ctrl-C to exit)
docker compose -f docker-compose-es.yaml up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker compose down
```

### Create Index Patterns
```sh
# pattern: 'myapp-order-*'
curl -X POST "localhost:5601/api/index_patterns/index_pattern" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "index_pattern": {
     "title": "myapp-order-*",
     "timeFieldName": "@timestamp"
  }
}
'

# pattern: 'myapp-login-*'
curl -X POST "localhost:5601/api/index_patterns/index_pattern" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "index_pattern": {
     "title": "myapp-login-*",
     "timeFieldName": "@timestamp"
  }
}
'

# pattern: 'myapp-click-*'
curl -X POST "localhost:5601/api/index_patterns/index_pattern" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "index_pattern": {
     "title": "myapp-click-*",
     "timeFieldName": "@timestamp"
  }
}
'
```

### Discover Data
- Visit `Kibana` to see data: [http://localhost:5601/app/discover#/](http://localhost:5601/)

<img src="./imgs/ElasticsearchDemoResult.jpg" width="700"/>



## Demo 3 (AWS OpenSearch)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and sends to `AWS OpenSearch`

<img src="./imgs/OpenSearchDemoOverview.jpg" width="700"/>

### Terraform
```sh
# Terraform (AWS OpenSearch)
cd tf
cp terraform.tfvars.example terraform.tfvars
## 1.Manually configure `terraform.tfvars` AWS `access_key` and `secret_key`
terraform init
## If there is an error related to service_linked_role, 
## just comment all "aws_iam_service_linked_role" in `tf/main.tf`.
## Note: It takes about 20-30 minutes to complete
terraform apply -auto-approve
## Only for demo, config for fluent-bit
terraform output > tf_output.log
cd ..
```

### Docker
```sh
# Deploy container (Ctrl-C to exit)
docker compose -f docker-compose-aws.yaml --env-file ./tf/tf_output.log up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag
```

### Manual work for the dashboard
#### Cognito User Pool
1. Go to AWS `Cognito` -> `User pools` -> `Create User`
2. Put the user into `master-group`

#### Cognito Identity Pool
- permission config, so that new user cannot access OpenSearch Dashboard
1. Go to AWS `Cognito` -> `Federated identities`
1. `myapp-identity-pool`
2. `Edit identity pool`
3. `Authentication providers`
   1. `Authenticated role selection`
   2. `Choose role from token`
   3. `DENY`
   4. `Save changes`

#### OpenSearch Dashboard
1. Go to AWS `OpenSearch` -> `myapp` -> `OpenSearch Dashboards URL`
2. Use new user email password to login
3. `Create Index Pattern` (left-side menu -> `Stack Management` -> `Index Patterns`)
   - `myapp-login-*` (timeField: `@timestamp`)
   - `myapp-order-*` (timeField: `@timestamp`)
   - `myapp-click-*` (timeField: `@timestamp`)
4. Go to `Discover` to view the results.
5. Permission config
   - left side menu `Security`
   - `Explore existing roles`
   - search `opensearch_dashboards_user` and `readall`
   - `Mapped users` -> `Map users`
   - In backend roles, enter arn of `myapp-cognito-auth-limited-role`. e.g. `arn:aws:iam::123456789:role/myapp-cognito-auth-limited-role`
   - Click `Map`

- After setting up Permission config, new user **without** a group has no permissions to enter the dashboard.

#### Discover Data

<img src="./imgs/OpenSearchDemoResult.jpg" width="700"/>

### Destroy
```sh
# Delete all container
docker compose down
# Delete AWS resources
## Note: It takes about 20-30 minutes to complete
cd tf
terraform destroy -auto-approve
```

## Trace Analytics
See [trace-analytics](./trace-analytics/)

## Frontend Logging
See [frontend-logging](./frontend-logging/)
