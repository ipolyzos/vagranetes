.PHONY: clean destroy master-ip kubectl-conf

# create the k8s cluster
cluster: 
	vagrant up
	rm -rf ./tmp

# destroy the k8s cluster
destroy:
	vagrant destroy --force

# configure kubectl conf env var
kubectl-conf:
	export KUBECONFIG=${PWD}/.kube/config

cluster-info: kubectl-conf
	kubectl cluster-info

vm-status:
	vagrant status

master-ip:
	vagrant ssh master -c "hostname -I | cut -d' ' -f 2"

# clean the workspace
clean: destroy
	rm -rf ./tmp/ ./.kube/
