terraform {
  backend "s3" {
    bucket = "kube.omegnet.com"
    key    = "vsphere/vspere.tfstate"
    region = "eu-west-1"
  }
}