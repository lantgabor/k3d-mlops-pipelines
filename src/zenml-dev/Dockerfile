FROM kubeflownotebookswg/codeserver-python:v1.7.0-rc.0

USER root
RUN apt update && \
    apt install -y curl && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

USER jovyan
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt