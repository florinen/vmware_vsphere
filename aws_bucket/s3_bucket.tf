
resource "aws_s3_bucket" "kube_omegnet" {
  bucket = "kube.omegnet.com"
  acl    = "private"
  region = "eu-west-1"

  versioning {
    enabled = true
  }
  tags = {
    Name        = "vSphere"
    Environment = "Dev"
  }
}
 terraform {
  backend "local" {
    path = "/root/.statefile/kube_omegnet.tfstate"
  }
}