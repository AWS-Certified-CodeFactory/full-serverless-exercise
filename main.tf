module "api" {
  source = "./api"

  org        = var.org
  env        = var.env
  aws_region = var.aws_region
}