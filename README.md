# Fluent-bit Client Settings

## Demo1 (stdout)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and prints on `stdout`

```sh
# Deploy container (Ctrl-C to exit)
docker-compose up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker-compose down
```

## Demo2 (elasticsearch)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and sends to `elasticsearch`


```sh
# Deploy container (Ctrl-C to exit)
docker-compose -f docker-compose-es.yaml up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker-compose down
```

- Open `kibana` to search
  - http://localhost:5601/
    - account: kibana
    - password: 123456
  - Create `Index Pattern`
    - Click `Stack Management`
    - Click `Index Patterns`
    - Click `Create Index Pattern`
      - Name: `myapp-order-*`, Timestamp field: `@timestamp`, Click `Create Index Pattern`
      - Name: `myapp-login-*`, Timestamp field: `@timestamp`, Click `Create Index Pattern`
      - Name: `myapp-click-*`, Timestamp field: `@timestamp`, Click `Create Index Pattern`
  - Checkout logs
    - Open left-side menu
    - Click `Discover` (under`Analytics`)
      - `myapp-order-*`
      - `myapp-login-*`

## Demo 3 (AWS OpenSearch)
- `test-app-stdout` prints log on `docker logs`
- `fluent-bit` collects logs and sends to `AWS OpenSearch`


```sh
# Terraform (AWS OpenSearch)
cd tf
cp terraform.tfvars.example terraform.tfvars
## Manually configure `terraform.tfvars` AWS `access_key` and `secret_key`
terraform init
terraform apply -auto-approve
## Only for demo, config for fluent-bit
terraform output > tf_output.log
cd ..

# Deploy container (Ctrl-C to exit)
docker-compose -f docker-compose-aws.yaml --env-file ./tf/tf_output.log up

# Test for frontend log
curl -d '{"log": "myapp-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag

# Delete all container
docker-compose down
```

### Manual work to enter dashboard
#### Cognito User Pool
1. Go to AWS `Cognito` -> `User pools` -> `Create User`, put the user into `master-group`

#### Cognito Identity Pool (permission config, so that new user cannot access OpenSearch Dashboard)
1. Go to AWS `Cognito` -> `Federated identities` -> `myapp-identity-pool` -> `Edit identity pool` -> `Authentication providers` -> `Authenticated role selection` -> `Choose role from token` -> `DENY` -> `Save changes`

#### OpenSearch Dashboard
1. Go to AWS `OpenSearch` -> `myapp` -> `OpenSearch Dashboards URL`
2. Use new user email password to login
3. `Create Index Pattern`
   - `myapp-login-*`
   - `myapp-order-*`
   - `myapp-click-*`
4. Go to `Discover` to view the results.
5. (for Permission config) Go to left side menu -> `Security` -> `Explore existing roles` -> search `opensearch_dashboards_user` -> `Mapped users` -> `Map users` -> In backend roles, enter arn of myapp-cognito-auth-limited-role. e.g. `arn:aws:iam::735106640944:role/myapp-cognito-auth-limited-role` -> `Map`

- After setting up Permission config, new user **without** a group has no permissions to enter the dashboard.
