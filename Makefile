SHELL=/usr/bin/bash

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: up
.PHONY: down
.PHONY: build
.PHONY: cluster-create cluster-delete
.PHONY: registry-create registry-delete

# for the k3d binary
# TODO: move to install dependecnies script
# K3D_VERSION ?= 5.4.6 
# K3D_BIN_URL = https://github.com/k3d-io/k3d/releases/download/$(K3D_VERSION)/k3d-linux-amd64

# k3d variables
K3D_CLUSTER_NAME ?= dev-cluster
K3D_SERVERS ?= 1
K3D_AGENTS ?= 1
K3D_API_PORT ?= 6510
K3D_EXPOSE_PORT ?= 8090

# Registry variables
K3D_REGISTRY_NAME ?= dev-registry
K3D_REGISTRY_PORT ?= 6502

# replace + with -, if needed
K3S_TAG ?= v1.23.8-k3s1
NVIDIA_CONTAINER_RUNTIME_VERSION ?= 3.12.0-1

IMAGE_REPOSITORY ?= rancher/k3s
IMAGE_TAG ?= $(K3S_TAG)-cuda
IMAGE ?= k3d-$(K3D_REGISTRY_NAME).localhost:$(K3D_REGISTRY_PORT)/$(IMAGE_REPOSITORY):$(IMAGE_TAG)

up: # Start the k3d cluster
	k3d cluster start $(K3D_CLUSTER_NAME)

down: # Stop the k3d cluster
	k3d cluster stop $(K3D_CLUSTER_NAME)

build-k3d-nvidia-image: # Build the custom nvidia image for the k3d gpu enabled cluster and push it to the registry
	@( docker build \
  		--build-arg K3S_TAG=$(K3S_TAG) \
  		--build-arg NVIDIA_CONTAINER_RUNTIME_VERSION=$(NVIDIA_CONTAINER_RUNTIME_VERSION) \
  		-t $(IMAGE) \
		-f $(PWD)/build/Dockerfile \
		$(PWD)/build )
	docker push $(IMAGE)
	@echo "Done!"

cluster-create: # Ceate the k3d cluster using the custom image
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

cluster-delete: # Destroy the k3d clsuter
	k3d cluster delete $(K3D_CLUSTER_NAME)

registry-create: # Create the private image registry
	mkdir -pv $(PWD)/data/registry
	@( k3d registry ls k3d-$(K3D_REGISTRY_NAME) && echo "Registry already exists") \
	|| k3d registry create $(K3D_REGISTRY_NAME) \
	--volume $(PWD)/data/registry:/var/lib/registry \
	--port $(K3D_REGISTRY_PORT)

registry-delete: # Delete the private image registry
	k3d registry delete $(K3D_REGISTRY_NAME)

get-kubeconfig: # Write the k3d cluster kubeconfig to the local kubeconfig dir
	k3d kubeconfig write $(K3D_CLUSTER_NAME)

get-k9s: # Run k9s the kubernetes dashborad from cli
	docker run --rm -it --network host -v $(KUBECONFIG):/root/.kube/config quay.io/derailed/k9s

registry-exec: # Exec into the registry, for debug purposes
	docker exec -it k3d-$(K3D_REGISTRY_NAME) /bin/sh

cluster-exec-server: # Exec into the k3d master node, for debug purposes
	docker exec -it k3d-$(K3D_CLUSTER_NAME)-server-0 /bin/bash

cluster-exec-agent: # Exec into the k3d worker node, for debug purposes
	docker exec -it k3d-$(K3D_CLUSTER_NAME)-agent-0 /bin/bash

cluster-get-ip: # Get the cluster ip address
	@docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq) | grep server-0 | cut -d' ' -f3

