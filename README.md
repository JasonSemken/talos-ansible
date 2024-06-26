**Introduction**

I had the idea to automate my Talo OS VM build with Ansible on my Proxmox host. While trying to reseach i found it hard to locate example Ansible configuration files for Proxmox. The aim of this 'Project' is to consolidate configuration files of Talos and the Proxmox providor for Ansible.


**Prerequisites**

With the aim to make this simple to pickup and modify for your deployment there are a few prerequisites to allow this build to work correctly.

1. DHCP reservations for each VM
    - The control-create.yaml and worker-create.yaml contains hardcoded MAC addresses. Create a DHCP reservation for each MAC address listed in these files.
    - The configuration files are set to work on the 10.250.0.0/24 subnet. Update the IPs you your subnet, detailed in the Talos Config section.

2. Proxmox host
    - The Proxmox host requires appications to be installed to allow the Proxmox provioder to function
    - SSH into the Proxmox host as root and run `pip install proxmox requests`
    if pip is not installed run `apt update && apt upgrade && apt install python-pip && pip --version`

3. Ansible and required dependicies installed on your device. Use Windows Sub-System for Linux if you are working on Windows.

4. An account created for Ansible to manage the Proxmox host.
    - This must be a PAM user, they are the only ones that are able to SSH into Proxmox.
    - Root can be used but not recommened


**Talos Config**

The included Talos config files will allow deployment after updating IP addresses that are hardcoded.

1. Update both 10.250.0.200 IPs in the /config/controlplane.yaml file with your DHCP IP assigned to the control node.
Line 48 and 84
2. Update the 10.250.0.200 IPs in the /config/worker.yaml file with your DHCP IP assigned to the control node.
Line 47
3. Update the 10.250.0.200 IPs in the /config/talosconfig file with your DHCP IP assigned to the control node.
Line 5 and 7

To create your own fresh run `talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out`
Add the IP that was assigned to the Control node in the DHCP reservation inplace of $CONTROL_PLANE_NODE

Note: You will need to rename the install disk name from '/dev/sda' to '/dev/vda' in both controlplane.yaml and worker.yaml. This is due to virtio disks being used on the VMs.
This is found under
` machine:
    install:
        disk:`


**Ansible Playbooks**

The inventory.yaml file will need to be updated to match your Proxmox hosts details. Notes can be found in the inventory file.

At the top of each playbook you will see a vars block. The below will need to match your environment.
These will be the same as your inventory file, excluding the proxmox_user it requires @pam appended to the username.
`
    proxmox_user: ansible@pam
    proxmox_pass: ansible
    proxmox_host: moxi
    proxmox_node: moxi
`

Note: The Credentials are listed in these files are for educational purposes, this is not recommeneded in production environements.


**Deployment**

The complete deployment has been packaged into a bash file, build.sh.
There is also a IP in the build.sh file that needs to be updated to your controlplane VM IP. This is found on line 11
`talosctl apply-config --insecure --nodes 10.250.0.200 --file config/controlplane.yaml`

Download files to your computer andstart a terminal session in the top folder.
Run `bash build.sh`

Note: The final command is used as a workaround to 'Update' the vm with a build that contains the QEMU agent. For some reason when you initally boot with a QEMU image pushing the config file will remove QEMU. I am yet to determine how to manage this with the config file.