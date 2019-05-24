#!/bin/bash

# Execute terraform apply to create the bucket
pushd aws_bucket
terraform init
terraform apply --auto-approve -var-file=../../config/data/vsphere.tfvars
popd
terraform init 
terraform apply --auto-approve -var-file=../config/data/vsphere.tfvars

# Executing ansible playbooks to install kubernetes cluster
pushd ansible
ansible-playbook -i terraform_hosts adduser.yaml
echo "adduser playbook finished"
ansible-playbook -i terraform_hosts kube-dependencies.yaml
echo "kube-dependencies playbook finished"
ansible-playbook -i terraform_hosts master.yaml
echo "master playbook finished"
ansible-playbook -i terraform_hosts workers.yaml
echo "worker playbook finished"

