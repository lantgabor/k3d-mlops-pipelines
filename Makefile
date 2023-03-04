.PHONY: up
.PHONY: down
.PHONY: build
.PHONY: cluster-create cluster-delete
.PHONY: registry-create registry-delete

K3D_VERSION ?= 5.4.6

K3D_CLUSTER_NAME ?= dev-cluster
K3D_SERVERS ?= 1
K3D_AGENTS ?= 1
K3D_API_PORT ?= 6510
K3D_EXPOSE_PORT ?= 8090

K3D_REGISTRY_NAME ?= dev-registry
K3D_REGISTRY_PORT ?= 6502

up:
	k3d cluster start $(K3D_CLUSTER_NAME)

down:
	k3d cluster stop $(K3D_CLUSTER_NAME)

cluster-create:
	mkdir -pv $(PWD)/data/containerd/{server-0, agent-0}
	mkdir -pv $(PWD)/data/kubelet/{server-0, agent-0}
	mkdir -pv $(PWD)/data/k3s-storage
	@( k3d cluster ls $(K3D_CLUSTER_NAME) && echo "Cluster already exists" ) \
	|| k3d cluster create $(K3D_CLUSTER_NAME) \
		--servers $(K3D_SERVERS) \
		--agents $(K3D_AGENTS) \
		--api-port $(K3D_API_PORT) \
		--registry-use k3d-$(K3D_REGISTRY_NAME):$(K3D_REGISTRY_PORT) \
		--volume $(PWD)/data/k3s-storage:/var/lib/rancher/k3s/storage \
		--port $(K3D_EXPOSE_PORT):80@loadbalancer

cluster-delete:
	k3d cluster delete $(K3D_CLUSTER_NAME)

registry-create:
	@( k3d registry ls k3d-$(K3D_REGISTRY_NAME) && echo "Registry already exists") \
	|| k3d registry create $(K3D_REGISTRY_NAME) \
	--port $(K3D_REGISTRY_PORT)

registry-delete:
	k3d registry delete $(K3D_REGISTRY_NAME)

get-kubeconfig:
	k3d kubeconfig write $(K3D_CLUSTER_NAME)

get-k9s:
	docker run --rm -it --network host -v $KUBECONFIG:/root/.kube/config quay.io/derailed/k9s