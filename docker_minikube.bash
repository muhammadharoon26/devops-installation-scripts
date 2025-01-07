#!/bin/bash

# Install prerequisites
echo "Installing prerequisites..."
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common wget

# Install Docker
echo "Installing Docker..."
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
docker --version

# Install Minikube
echo "Installing Minikube..."
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O minikube
sudo mv minikube /usr/local/bin/minikube
sudo chmod +x /usr/local/bin/minikube
minikube version

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
kubectl version --client -o yaml

# Start Minikube with Docker driver
echo "Starting Minikube..."
minikube start --driver=docker
minikube status

echo "Installation completed successfully!"
