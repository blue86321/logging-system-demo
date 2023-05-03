
# search slow log
resource "aws_cloudwatch_log_group" "search_slow" {
  name = "/aws/OpenSearchService/domains/${var.domain_name}/search-slow-logs"
}

data "aws_iam_policy_document" "es_search_slow_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = [aws_cloudwatch_log_group.search_slow.arn]
  }
}

resource "aws_cloudwatch_log_resource_policy" "es_search_slow_policy" {
  policy_document = data.aws_iam_policy_document.es_search_slow_policy_doc.json
  policy_name     = "${var.domain_name}-OpenSearchService-search-slow-logs"
}



# index slow log
resource "aws_cloudwatch_log_group" "index_solw" {
  name = "/aws/OpenSearchService/domains/${var.domain_name}/index-slow-logs"
}

data "aws_iam_policy_document" "es_index_solw_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = [aws_cloudwatch_log_group.index_solw.arn]
  }
}

resource "aws_cloudwatch_log_resource_policy" "es_index_solw_policy" {
  policy_document = data.aws_iam_policy_document.es_index_solw_policy_doc.json
  policy_name     = "${var.domain_name}-OpenSearchService-index-slow-logs"
}



# error logs
resource "aws_cloudwatch_log_group" "error" {
  name = "/aws/OpenSearchService/domains/${var.domain_name}/error-logs"
}

data "aws_iam_policy_document" "es_error_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = [aws_cloudwatch_log_group.error.arn]
  }
}

resource "aws_cloudwatch_log_resource_policy" "es_error_policy" {
  policy_document = data.aws_iam_policy_document.es_error_policy_doc.json
  policy_name     = "${var.domain_name}-OpenSearchService-error-logs"
}
