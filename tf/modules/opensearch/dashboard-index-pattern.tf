resource "opensearch_dashboard_object" "click" {
  index = ".kibana"
  body = <<EOF
    [
      {
        "_id": "index-pattern:${var.domain_name}-click",
        "_type": "_doc",
        "_source": {
          "type": "index-pattern",
          "index-pattern": {
            "title": "${var.domain_name}-click-*",
            "timeFieldName": "@timestamp"
          }
        }
      }
    ]
  EOF
}

resource "opensearch_dashboard_object" "order" {
  index = ".kibana"
  body = <<EOF
    [
      {
        "_id": "index-pattern:${var.domain_name}-order",
        "_type": "_doc",
        "_source": {
          "type": "index-pattern",
          "index-pattern": {
            "title": "${var.domain_name}-order-*",
            "timeFieldName": "@timestamp"
          }
        }
      }
    ]
  EOF
}


resource "opensearch_dashboard_object" "login" {
  index = ".kibana"
  body = <<EOF
    [
      {
        "_id": "index-pattern:${var.domain_name}-login",
        "_index": ".kibana_1",
        "_type": "_doc",
        "_source": {
          "type": "index-pattern",
          "index-pattern": {
            "title": "${var.domain_name}-login-*",
            "timeFieldName": "@timestamp"
          }
        }
      }
    ]
  EOF
}
