# Logging System Demo

## Overview
This demo is to show how to implement a logging system.
- **Demo1**: Fluent Bit simply collect loggings and output to stdout
- **Demo2**: Fluent Bit collect loggings and output to Elasticsearch and Kibana
- **Demo3**: Fluent Bit collect loggings and output to AWS OpenSearch
- **Trace Analytics**: traces demo and append `trace-id` and `span-id` to loggings.

## Demo1 (stdout)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and prints on `stdout`

<img src="./imgs/StdoutDemo.jpg" width="500"/>


```sh
# Deploy container (Ctrl-C to exit)
docker compose up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker compose down
```

## Demo2 (elasticsearch)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and sends to `elasticsearch`

<img src="./imgs/ElasticsearchDemo.jpg" width="700"/>

```sh
# Deploy container (Ctrl-C to exit)
docker compose -f docker-compose-es.yaml up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker compose down
```

- Open `kibana` to search
  - [http://localhost:5601/](http://localhost:5601/)
  - Login if needed
    - account: kibana
    - password: 123456
  - Create `Index Pattern`
    - Click `Stack Management`
    - Click `Index Patterns`
    - Click `Create Index Pattern`
      - Name: `myapp-order-*`, Timestamp field: `@timestamp`, Click `Create Index Pattern`
      - Name: `myapp-login-*`, Timestamp field: `@timestamp`, Click `Create Index Pattern`
      - Name: `myapp-click-*`, Timestamp field: `@timestamp`, Click `Create Index Pattern`
  - Check out logs
    - Open left-side menu
    - Click `Discover` (under`Analytics`)
      - `myapp-order-*`
      - `myapp-login-*`
      - `myapp-click-*`

## Demo 3 (AWS OpenSearch)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and sends to `AWS OpenSearch`

<img src="./imgs/OpenSearchDemo.jpg" width="700"/>

```sh
# Terraform (AWS OpenSearch)
cd tf
cp terraform.tfvars.example terraform.tfvars
## 1.Manually configure `terraform.tfvars` AWS `access_key` and `secret_key`
terraform init
terraform apply -auto-approve
## Only for demo, config for fluent-bit
terraform output > tf_output.log
cd ..

# Deploy container (Ctrl-C to exit)
docker compose -f docker-compose-aws.yaml --env-file ./tf/tf_output.log up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker compose down
# Delete AWS resources
cd tf
terraform destroy -auto-approve
```

### Manual work to enter dashboard
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
3. `Create Index Pattern`
   - `myapp-login-*`
   - `myapp-order-*`
   - `myapp-click-*`
4. Go to `Discover` to view the results.
5. Permission config
   - left side menu `Security`
   - `Explore existing roles`
   - search `opensearch_dashboards_user` and `readall`
   - `Mapped users` -> `Map users`
   - In backend roles, enter arn of `myapp-cognito-auth-limited-role`. e.g. `arn:aws:iam::123456789:role/myapp-cognito-auth-limited-role`
   - Click `Map`

- After setting up Permission config, new user **without** a group has no permissions to enter the dashboard.


## Trace Analytics
See [trace-analytics](./trace-analytics/)
