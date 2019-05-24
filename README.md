## Creating kubernetes cluster with Terraform and Ansible on vmware vsphere
## Prerequisites:
Create one Centos 7 vm
After creation is finished, login and do the following:
  - yum install -y open-vm-tools  # or you can manualy install from vmware install disk 
  - yum install -y perl 			 # without this package when VM starts network will be in disconnected state. 
  - you can create a user and generate ssh keys for the user if needed
  - replace dhcp with static IP in network interface ifcfg-ens192	 #if not set to static even if you set static IP in terraform, DHCP server will always set the ip 
  - shutdown vm

## In vCenter
  - take a snapshot of the template virtual machine. This snapshot will be used to do a linked clone of the template into several virtual machines.
  - convert the virtual machine to a template
  - move the template to the new template folder
  
## Create user and roles for the vSphere Cloud Provider 
1) Add user that terraform will use to create infrastructure
2) Create a role to view the profile-driven storage
3) Create a role to manage the Kubernetes nodes virtual machines
   role name: manage-node-vms
   -resources 
         -assign virtual machine to resource pool
   -Virtual Machine
         -configuration
		        -add existing disk
				-add new disk
				-add or remove device
				-remove disk
		 -inventory
		        -create
				-remove
4) Create a new role to manage the Kubernetes volumes.
   role name: manage-kube-volumes
         -datastore
		        -allocate space
				-low level file operation

## Assign permission to the vSphere Cloud Provider user that we created:

1) Add the read-only permission at the datacenter level. Remove the propagation of the permission
2) Add the profile-driven storage view at the vCenter level. Remove the propagation of the permission.
3) Add the manage node permission at the cluster level. This cluster is the cluster where the Kubernetes nodes will be deployed. 
Keep the propagation of the permission
4- Add the manage volumes permission at the datastore level. This datastore will be the datastore where the Kubernetes volumes will be created. 
Remove the propagation of the permission. Could be done at the cluster datastore level if one exists

Create a directory for the vSphere Cloud Provider, This folder will store the virtual disks created by the vSphere Cloud Provider. (optionally) 

# To run terraform and ansible execute the folowing script:
  
  - chmod +x install_cluster.sh         # if script is not executable, make it with this cmd
  - ./install_cluster.sh                # executing this script will installl kubernetes cluster.