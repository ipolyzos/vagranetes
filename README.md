# Vagranetes

A Kubernetes multi-node set up by kubeadm in Vagrant machines. The project stands as the next generation of [vagrant-kube](http://github.com/ipolyzos/vagrant-kube) and the implementation is based on a vagrant based script for setting up a multi-node Kubernetes cluster using Kubeadm. It aims to serve as a local testbed and test environment of current kubernetes version.

## Pre-requisites
 * **[Virtualbox 5.2.18+](https://www.virtualbox.org)**
 * **[Vagrant 2.1.4+](https://www.vagrantup.com)**

## Deployment 
 * **[Kubernetes](https://kubernetes.io)** 
 * **[CRI-o](https://cri-o.io/)** 
 * **[Docker](https://docker.io)**

## How to deploy
In order to deploy a new cluster execute the following command to remove the virtual machines.
```
$ make cluster 
```

_``
Note:
    or just `make`
``_

## Kubectl config

For the location of the config file and the _kubectl_ `export` directive please execute the following command.
```
$ make kubectl-conf
```

## Destroy

In order to destroy any running vms and clean your hypervisor, execute the following command to remove the virtual machines created for the Kubernetes cluster.
```
$ make destroy
```

You can also destroy individual machines by executing the `vagrant destroy` command e.g `vagrant destroy node-1 -f`

## Clean-up

In order to clean your workspace both from VMS, configuration and temporary files and running VMs execute the following command.
```
make clean
```

## Install a network add-on

A complete list of add-ons to further complement your cluster can be found at [Installing Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/) page. 

``
Note:
    it is critical to proceed with an network add-on installation
``


##  License:

   Copyright 2019 Ioannis Polyzos

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
