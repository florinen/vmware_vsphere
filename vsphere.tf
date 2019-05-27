#===============================================================================
# vSphere Provider
#===============================================================================

provider "vsphere" {
  #version        = "1.11.0"
  vsphere_server = "${var.vsphere_vcenter}"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"

  allow_unverified_ssl = "${var.vsphere_unverified_ssl}"
}

#===============================================================================
# vSphere Data
#===============================================================================

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_drs_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vm_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vm_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


#===============================================================================
# vSphere Resources
#===============================================================================

# Create a virtual machine folder for the Kubernetes VMs #
resource "vsphere_folder" "folder" {
  path          = "${var.vm_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Create a resource pool for the Kubernetes VMs #
resource "vsphere_resource_pool" "resource_pool" {
  name                    = "${var.vsphere_resource_pool}"
  parent_resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
}

# Create the Kubernetes master VMs #
resource "vsphere_virtual_machine" "master" {
  count            = "${length(var.vm_master_ips)}"
  name             = "${var.vm_name_prefix}-master-${count.index}"
  resource_pool_id = "${vsphere_resource_pool.resource_pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.folder.path}"

  num_cpus         = "${var.vm_master_cpu}"
  memory           = "${var.vm_master_ram}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  enable_disk_uuid = "true"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "${var.vm_name_prefix}-master-${count.index}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disk.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      timeout = "20"

      linux_options {
        host_name = "${var.vm_name_prefix}-master-${count.index}"
        domain    = "${var.vm_domain}"
      }

      network_interface {
        ipv4_address = "${lookup(var.vm_master_ips, count.index)}"
        ipv4_netmask = "${var.vm_netmask}"
        
      }

      ipv4_gateway    = "${var.vm_gateway}"
      dns_server_list = ["${var.vm_dns}"]
    }
  }
  # Copy host SSH pub key to remote hosts
  connection {
    host    = "${vsphere_virtual_machine.master.*.ipv4_address}"
    type     = "ssh"
    user     = "${var.vm_admin_user}"
    password = "${var.vm_admin_password}"
  }
  provisioner "file" {
    source      = "${file("~/.ssh/id_rsa.pub")}"
    destination = "/root/.ssh/authorized_keys"
  }
}

# Create the Kubernetes worker VMs #
resource "vsphere_virtual_machine" "worker" {
  count            = "${length(var.vm_worker_ips)}"
  name             = "${var.vm_name_prefix}-worker-${count.index}"
  resource_pool_id = "${vsphere_resource_pool.resource_pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.folder.path}"
  
  num_cpus         = "${var.vm_worker_cpu}"
  memory           = "${var.vm_worker_ram}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  enable_disk_uuid = "true"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "${var.vm_name_prefix}-worker-${count.index}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      timeout = "20"

      linux_options {
        host_name = "${var.vm_name_prefix}-worker-${count.index}"
        domain    = "${var.vm_domain}"
      }

      network_interface {
        ipv4_address = "${lookup(var.vm_worker_ips, count.index)}"
        ipv4_netmask = "${var.vm_netmask}"
      }

      ipv4_gateway    = "${var.vm_gateway}"
      dns_server_list = ["${var.vm_dns}"]
    }
  }
# Copy host SSH pub key to remote hosts
 
  connection {
    host     = "${lookup(var.vm_worker_ips, count.index)}"
    type     = "ssh"
    user     = "${var.vm_admin_user}"
    password = "${var.vm_admin_password}"
  }

  provisioner "file" {
    source      = "${var.ssh_keys}"
    destination = "/root/.ssh/authorized_keys"
  }
  
  
}
# Create anti affinity rule for the Kubernetes master VMs #
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "master_anti_affinity_rule" {
  count               = "${var.vsphere_enable_anti_affinity == "true" ? 1 : 0}"
  name                = "${var.vm_name_prefix}-master-anti-affinity-rule"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = ["${vsphere_virtual_machine.master.*.id}"]

  depends_on = ["vsphere_virtual_machine.master"]
}
