
provider "aws" {
  region = "eu-central-1"
}

resource "aws_dynamodb_table" "demoTable" {
  name                        = "demo-inexplicable-type-discrepancy"
  table_class                 = "STANDARD"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false

  point_in_time_recovery {
    enabled = false
  }

  hash_key  = "key1"
  range_key = "dim1"

  attribute {
    name = "key1"
    type = "S"
  }

  attribute {
    name = "dim1"
    type = "S"
  }
}

output "demo_table_name" {
  value = aws_dynamodb_table.demoTable.name
}

resource "aws_appsync_graphql_api" "demoAPI" {
  name                = "demo-inexplicable-type-discrepancy-api"
  authentication_type = "API_KEY"

  schema = <<EOF
type Query {
  testTripleEq(id: String, value: Int): String @aws_auth
}
EOF
}

resource "aws_appsync_api_key" "demoAPI" {
  api_id  = aws_appsync_graphql_api.demoAPI.id
  expires = timeadd(timestamp(), "${24 * 354}h")
}

resource "aws_appsync_datasource" "demoTable" {
  name             = "SourceDDB"
  type             = "AMAZON_DYNAMODB"
  api_id           = aws_appsync_graphql_api.demoAPI.id
  service_role_arn = aws_iam_role.demoTable.arn

  dynamodb_config {
    region     = "eu-central-1"
    table_name = aws_dynamodb_table.demoTable.name
  }
}

resource "aws_iam_role" "demoTable" {
  name               = "role-demo-inexplicable-type-discrepancy-ddb"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "appsync.amazonaws.com"
    }
  }]
}
EOF

  inline_policy {
    name = "policy-demo-inexplicable-type-discrepancy-ddb"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [{
        "Sid" : "AllowLogs",
        "Effect" : "Allow",
        "Action" : [
          "logs:*"
        ],
        "Resource" : "*"
        }, {
        "Sid" : "AllowDynamoDB",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : [
          "${aws_dynamodb_table.demoTable.arn}",
          "${aws_dynamodb_table.demoTable.arn}/index/*"
        ]
      }]
    })
  }
}

resource "aws_appsync_function" "demoTestTripleEq" {
  api_id      = aws_appsync_graphql_api.demoAPI.id
  data_source = aws_appsync_datasource.demoTable.name
  name        = "testTripleEq"
  code        = file("${path.module}/query/testTripleEq.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_resolver" "demoTestTripleEq" {
  type              = "Query"
  field             = "testTripleEq"
  kind              = "PIPELINE"
  api_id            = aws_appsync_graphql_api.demoAPI.id
  request_template  = "{}"
  response_template = "$util.toJson($ctx.result)"

  pipeline_config {
    functions = [aws_appsync_function.demoTestTripleEq.function_id]
  }
}
