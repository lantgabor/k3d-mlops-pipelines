#!/bin/bash 

# Kustomize 5.0 has been fixed by #2399 Mar 13, 2023

while ! kustomize build example | awk '!/well-defined/' | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done