terraform {
  backend "s3" {
    bucket = "kube.omegnet.com"
    key    = "vsphere/vsphere.tfstate"
    region = "eu-west-1"
  }
}