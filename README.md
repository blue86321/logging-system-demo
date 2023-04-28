# Fluent-bit Client Settings

## Demo1 (stdout)
- `test-app-stdout` 將日誌打印在 docker logs 上
- `fluent-bit` 採集後直接輸出在 stdout

```sh
# 部署 container (Ctrl-C 退出)
docker-compose up
# 測試前端日誌
curl -d '{"log": "ggo-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag
# 刪除所有相關 container
docker-compose down
```

## Demo2 (elasticsearch)
- `test-app-stdout` 將日誌打印在 docker logs 上
- `fluent-bit` 採集後發送到 `elasticsearch`


```sh
# 部署 container (Ctrl-C 退出)
docker-compose -f docker-compose-es.yaml up
# 測試前端日誌
curl -d '{"log": "ggo-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag
# 刪除所有相關 container
docker-compose down
```

- 打開 `kibana` 查詢
  - http://localhost:5601/
  - 創建 Index Pattern
    - 點擊 `Stack Management`
    - 點擊 `Index Patterns`
    - 點擊 `Create Index Pattern`
      - Name 輸入 `ggo-order-*`, Timestamp field 選擇 `@timestamp`, 點擊 `Create Index Pattern`
      - Name 輸入 `ggo-login-*`, Timestamp field 選擇 `@timestamp`, 點擊 `Create Index Pattern`
      - Name 輸入 `ggo-click-*`, Timestamp field 選擇 `@timestamp`, 點擊 `Create Index Pattern`
  - 查看日誌
    - 打開左邊側菜單
    - 點擊 `Analytics` 下的 `Discover` 即可查看日誌
      - `ggo-order-*`
      - `ggo-login-*`

## Demo 3 (AWS OpenSearch)
- `test-app-stdout` 將日誌打印在 docker logs 上
- `fluent-bit` 採集後發送到 `AWS OpenSearch`


```sh
# Terraform (AWS OpenSearch)
cd tf
cp terraform.tfvars.example terraform.tfvars
## 配置 `terraform.tfvars` 中的 AWS `access_key` and `secret_key`
terraform init
terraform apply -auto-approve
terraform output > tf_output.log
cd ..
# 部署 container (Ctrl-C 退出)
docker-compose -f docker-compose-aws.yaml --env-file ./tf/tf_output.log up
# 測試前端日誌
curl -d '{"log": "ggo-click","click_text": "action.goBack","uid": "1", "time": "2023-04-07T06:58:28.123456"}' -XPOST -H "content-type: application/json" http://localhost:9880/frontendTag
# 刪除所有相關 container
docker-compose down
```

### Manual work to enter dashboard
#### Cognito User Pool
1. Go to AWS `Cognito` -> `User pools` -> `Create User`, put the user into `master-group`

#### Cognito Identity Pool (for Permission config)
1. Go to AWS `Cognito` -> `Federated identities` -> `ggo-opensearch-identity-pool` -> `Edit identity pool` -> `Authentication providers` -> `Authenticated role selection` -> `Choose role from token` -> `DENY` -> `Save changes`

#### OpenSearch Dashboard
1. Go to AWS `OpenSearch` -> `ggo-opensearch` -> `OpenSearch Dashboards URL`
2. Use new user email password to login
3. `Create Index Pattern`
   - `ggo-login-*`
   - `ggo-order-*`
   - `ggo-click-*`
4. Go to `Discover` to view the results.
5. (for Permission config) Go to left side menu -> `Security` -> `Explore existing roles` -> search `opensearch_dashboards_user` -> `Mapped users` -> `Map users` -> In backend roles, enter arn of Cognito_ggoopensearch_Auth_Limited_Role. e.g. `arn:aws:iam::735106640944:role/Cognito_ggoopensearch_Auth_Limited_Role` -> `Map`

- After setting up Permission config, new user **without** a group has no permissions to enter the dashboard.
