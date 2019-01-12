# -*- mode: ruby -*-
# vi: set ft=ruby :

# This script to install common Kubernetes packages and is to be used
# in all VMS i.e both master and node VMs 
$script = <<-SCRIPT
# Install Docker CE
## Set up the repository:
### Update the apt package index
apt-get update

### Install packages to allow apt to use a repository over HTTPS
apt-get install -y apt-transport-https ca-certificates curl software-properties-common 

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install docker ce.
apt-get update && apt-get install -y docker-ce=18.06.2~ce~3-0~ubuntu
apt-mark hold docker-ce 

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

# Install CRI-O - Prerequisites
modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# Install prerequisites
apt-get install -y software-properties-common

add-apt-repository ppa:projectatomic/ppa
apt-get update

# Install CRI-O
apt-get install -y cri-o-1.11
sudo apt-mark hold cri-o-1.11

systemctl start crio

# Installing kubeadm, kubelet and kubectl
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update && apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Kubelet requires swap off
swapoff -a

# Keep swap off after reboot
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

systemctl daemon-reload
systemctl restart kubelet

# get the IP address Hostname and CIDR that has given this VM
LIPADDR=`ifconfig eth0 | grep -i mask | awk '{print $2}'| cut -f2 -d:`
IPADDR=`ifconfig eth1 | grep -i mask | awk '{print $2}'| cut -f2 -d:`
NODENAME=$(hostname -s) 
CIDR=`ip route show | grep eth1 | cut -f1 -d' '`
echo "VM's details are: \n IP address: ${IPADDR} \n Hostname: ${NODENAME} \n CIDR: ${CIDR}"

# Initialise the kubernetes cluster based on the machine type
if [[ $NODENAME =~ "master" ]]
then

 # Revert any changes may have taken place on this host
 sudo kubeadm reset -f

 # Pulling images for setting up Kubernetes cluster
 kubeadm config images pull

 # Setup make kubernetes master
 sudo kubeadm init --pod-network-cidr=${CIDR} \
                   --node-name ${NODENAME} \
                   --apiserver-advertise-address ${IPADDR} \
                   --apiserver-cert-extra-sans="${LIPADDR},${IPADDR}" \
                   --ignore-preflight-errors=SystemVerification \
                   --skip-token-print
 
 # Create /.kube dirs and copy config
 mkdir -p {$HOME/.kube,/vagrant/.kube}                                                                    
 echo /vagrant/.kube/config  $HOME/.kube/config | xargs -n 1 \\cp -v /etc/kubernetes/admin.conf 
                                                                                                                                                           
 sudo chown $(id -u vagrant):$(id -g vagrant) /vagrant/.kube/config $HOME/.kube/config

 # Create a temporaty join script for nodes
 [[ -d /vagrant/tmp ]] || mkdir -p /vagrant/tmp
cat > /vagrant/tmp/join.sh << EOF
#!/bin/bash

$(sudo kubeadm token create --print-join-command)
EOF

 chmod +x /vagrant/tmp/join.sh

elif [[ $NODENAME =~ "node" ]]
then 
  /vagrant/tmp/join.sh

else
 # sanity check, jut in case the script run in an unknown machine
 echo "This machine is not recogined!"
 exit 0
fi


SCRIPT

##
#  Vagrant confiuration 
Vagrant.configure("2") do |config|

  ##
  # Common configuration for all VMs
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.network "private_network", type: "dhcp"
  config.vm.provision "shell", inline: $script

  ##
  # Master configuration
  #
  # Note: 
  #  Target a sigle master deployment
  #
  config.vm.define "master", primary: true  do |mstr|
  	mstr.vm.hostname = "master"
    mstr.vm.provider :virtualbox do |v|
      v.cpus=2
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--name", "master"]
    end
  end

  ##
  # Nodes configuration
  #
  # Note:
  #  Target multiple nodes deployment
  #
  (1..3).each do |i|
    config.vm.define "node-#{i}" do |nd|
      nd.vm.hostname = "node-#{i}"
      nd.vm.provider :virtualbox do |v|
      	v.cpus=2
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--name", "node-#{i}"]
      end
    end
  end

end