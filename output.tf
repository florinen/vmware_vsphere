output "ip_addresses" {
  value = ["${vsphere_virtual_machine.master.*.default_ip_address}","${vsphere_virtual_machine.worker.*.default_ip_address}"]
}
output "virtual_machine_names" {
  description = "The names of each virtual machine deployed."
  value = ["${flatten(list(
    vsphere_virtual_machine.master.*.name,
    vsphere_virtual_machine.worker.*.name,
  ))}"]
}

output "virtual_machine_ids" {
  description = "The ID of each virtual machine deployed, indexed by name."
  value = "${zipmap(
    flatten(list(
      vsphere_virtual_machine.master.*.name,
      vsphere_virtual_machine.worker.*.name,
    )),
    flatten(list(
      vsphere_virtual_machine.master.*.id,
      vsphere_virtual_machine.worker.*.id,
      )),
  )}"
}
#output "virtual_machine_default_ips" {

 # description = "The default IP address of each virtual machine deployed, indexed by name."
  #value = "${zipmap(
   # flatten(list(
    # vsphere_virtual_machine.worker.*.name,
    #)),
    #flatten(list(
    # vsphere_virtual_machine.master.*.default_ip_address,
    # vsphere_virtual_machine.worker.*.default_ip_address,
     #)),
  #)}"
#}

    