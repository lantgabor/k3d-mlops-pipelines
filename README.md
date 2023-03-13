# Init

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
