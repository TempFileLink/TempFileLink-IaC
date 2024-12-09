resource "aws_lambda_function" "s3_cleanup" {
  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")
  function_name    = "s3-cleanup-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "bootstrap" 
  runtime         = "provided.al2"  

  environment {
    variables = {
      DB_HOST     = module.db.db_instance_address
      DB_PORT     = "5432"
      DB_USER     = var.rds.db_user
      DB_PASS     = var.rds.db_pass
      DB_NAME     = var.rds.database_name
      AWS_BUCKET_NAME = module.s3_bucket.s3_bucket_id
    }
  }

  vpc_config {
    subnet_ids         = module.vpc.database_subnets
    security_group_ids = [module.lambda_sg.security_group_id]
  }

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_cleanup.function_name 
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_bucket.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3_bucket.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_cleanup.arn
    events              = ["s3:ObjectRemoved:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_bucket,
    aws_iam_role_policy.lambda_s3_policy,
    aws_lambda_function.s3_cleanup
  ]
}