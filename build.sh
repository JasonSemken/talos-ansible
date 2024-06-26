echo "BUILD CONTROL SENT TO ANSIBLE"
ansible-playbook -i inventory.yaml playbooks/control-create.yaml

echo "SENDING CONTROL CONFIG IN 30 SECONDS"
sleep 30s

echo "SENDING CONTROL CONFIG"
# --nodes is the IP or FQDN of the control node
talosctl apply-config --insecure --nodes 10.250.0.200 --file config/controlplane.yaml

echo "CONFIG SENT"

export TALOSCONFIG="config/talosconfig"
talosctl config endpoint 10.250.0.200  #IP or FQDN of the control node
talosctl config node 10.250.0.200  #IP or FQDN of the control node

echo "BOOTSTRAPING CLUSTER IN 90 SECONDS"
sleep 90s

echo "BOOTSTRAP CLUSTER"
talosctl bootstrap

echo "UPGRADING CLUSTER IN 120 SECONDS"
sleep 120s

echo "UPGRADING IMAGE FOR QEMU"
talosctl upgrade --image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.7.4 -m powercycle --preserve