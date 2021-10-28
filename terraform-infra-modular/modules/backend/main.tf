terraform {
  backend "s3" {
    bucket = var.var_aws_bucket_id
    key = "tfstate/test/terraform.tfstate"
    region = var.var_region
    dynamodb_table = "cyber94_calc_cmetcalfe_dynamodb_table_lock"
    attribute {
      name = "LockID"
      type = "S"
    }
    lifecycle {
      prevent_destroy = true
    }
    encrypt = true
  }
}
