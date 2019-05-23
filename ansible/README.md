# kubernetes_ansible

For this playbook to work, you will need to have at least one master wnd two workers and in my case i use Centos 7 x64 minimal.
Things you should know befor running playbook:
 - firewalld will have to be disabled or it will conflict with iptables
 - Changing the cgroup driver of a Node such that your container runtime and kubelet use systemd as the cgroup driver or you will not be able to initialize the cluster.
   i followed this tutorial https://kubernetes.io/docs/setup/cri/
To run a playbook:
```
ansible-playbook -i terraform_hosts adduser.yaml
```
