#!/bin/bash

# Install Docker
sudo apt update
sudo apt install -y docker.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Install kubeadm, kubelet, and kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Disable swap on Ubuntu
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Initialize Kubernetes cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubeconfig for non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico network plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Allow scheduling pods on the control plane node (if needed)
kubectl taint nodes --all node-role.kubernetes.io/master-

# Install Helm (optional)
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh

# Install nginx ingress controller (optional)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml

# Print cluster information
echo "Kubernetes cluster is now initialized."
echo "You can check cluster nodes by running: kubectl get nodes"
