.PHONY: up
.PHONY: down
.PHONY: build
.PHONY: cluster-create cluster-delete
.PHONY: registry-create registry-delete

# for the k3d binary
# K3D_VERSION ?= 5.4.6 
# K3D_BIN_URL = https://github.com/k3d-io/k3d/releases/download/$(K3D_VERSION)/k3d-linux-amd64

K3D_CLUSTER_NAME ?= dev-cluster
K3D_SERVERS ?= 1
K3D_AGENTS ?= 1
K3D_API_PORT ?= 6510
K3D_EXPOSE_PORT ?= 8090

K3D_REGISTRY_NAME ?= dev-registry
K3D_REGISTRY_PORT ?= 6502

# replace + with -, if needed
K3S_TAG ?= v1.23.8-k3s1
IMAGE_REPOSITORY ?= rancher/k3s
IMAGE_TAG ?= $(K3S_TAG)-cuda
IMAGE ?= k3d-$(K3D_REGISTRY_NAME).localhost:$(K3D_REGISTRY_PORT)/$(IMAGE_REPOSITORY):$(IMAGE_TAG)

NVIDIA_CONTAINER_RUNTIME_VERSION ?= 3.12.0-1
up:
	k3d cluster start $(K3D_CLUSTER_NAME)

down:
	k3d cluster stop $(K3D_CLUSTER_NAME)

build-k3d-nvidia-image:
	@( docker build \
  		--build-arg K3S_TAG=$(K3S_TAG) \
  		--build-arg NVIDIA_CONTAINER_RUNTIME_VERSION=$(NVIDIA_CONTAINER_RUNTIME_VERSION) \
  		-t $(IMAGE) \
		-f $(PWD)/build/Dockerfile \
		$(PWD)/build )
	docker push $(IMAGE)
	@echo "Done!"

cluster-create:
	mkdir -pv $(PWD)/data/containerd/{server-0,agent-0}
	mkdir -pv $(PWD)/data/kubelet/{server-0,agent-0}
	mkdir -pv $(PWD)/data/k3s-storage
	@( k3d cluster ls $(K3D_CLUSTER_NAME) && echo "Cluster already exists" ) \
	|| k3d cluster create $(K3D_CLUSTER_NAME) \
		--image $(IMAGE) \
		--gpus 1 \
		--servers $(K3D_SERVERS) \
		--agents $(K3D_AGENTS) \
		--api-port $(K3D_API_PORT) \
		--registry-use k3d-$(K3D_REGISTRY_NAME):$(K3D_REGISTRY_PORT) \
		--volume $(PWD)/data/k3s-storage:/var/lib/rancher/k3s/storage \
		--volume $(PWD)/data/containerd/server-0:/var/lib/rancher/k3s/agent/containerd@server:0 \
		--volume $(PWD)/data/containerd/agent-0:/var/lib/rancher/k3s/agent/containerd@agent:0 \
		--volume $(PWD)/data/kubelet/server-0:/var/lib/kubelet:shared@server:0 \
		--volume $(PWD)/data/kubelet/agent-0:/var/lib/kubelet:shared@agent:0 \
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

cluster-exec-server:
	docker exec -it k3d-$(K3D_CLUSTER_NAME)-server-0 /bin/bash