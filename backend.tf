terraform {
  backend "s3" {
    bucket = "kube.omegnet.com"
    key    = "vsphere-terraform"
    region = "eu-west-1"
  }
}