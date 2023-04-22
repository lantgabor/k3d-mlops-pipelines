# Testing MLOps pipelines using a local k3d cluster with Nvidia GPU support enabled

The goal of this project is to create and test a reproducible MLOps pipeline using the currently available tools on a kubernetes cluster.

For local development purposes I created this repo to use and deploy a [k3d](https://k3d.io/) cluster with Nvidia GPU support.

## How to use

Makefile holds all the install scripts for the cluster setup.

Usage:

1. Create local regisrty `make registry-create`
2. Build and push nvidia image for GPU support `make build-k3d-nvidia-image`
3. Create the k3d cluster `make cluster-create`
4. Start the k3d cluster `make up`

## Environment

- Ubuntu 22.04.2 LTS
- nvidia driver version 525.85.05
- cuda version 12.0

## Dependencies

- [Make](https://www.gnu.org/software/make/)

  ```bash
  sudo apt update && sudo apt install -y make
  ```

- [k3d](https://k3d.io/)

  ```bash
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  ```

- [Helm](https://helm.sh/)

  ```bash
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  ```

- [Kustomize](https://kustomize.io/)

  ```bash
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

  mv kustomize /usr/local/bin
  ```

# Kubeflow install

## Install

1. **Ubuntu 22.04:**

   :warning: Known bug: Make sure to have enough file descriptors for open files, if you get this error: Too many open files in the logs. Fix: [Configuring Linux for Many Watch Folders](https://www.ibm.com/docs/en/aspera-on-demand/3.9?topic=line-configuring-linux-many-watch-folders)

1. Clone and install: [kubeflow/manifests](https://github.com/kubeflow/manifests)

   ```bash
   while ! kustomize build example | awk '!/well-defined/' | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
   ```

   :warning: `Kustomize 5.0` has been fixed by #2399 Mar 13, 2023

## Adding an ingress to access from the browser

To reach the istio service gateway on localhost that forwards the traffic of the kubeflow gui we need to add an ingress to the cluster. By default k3d is configured with `traefik` ingress controller. [Exposing services](https://k3d.io/v5.4.6/usage/exposing_services/)
