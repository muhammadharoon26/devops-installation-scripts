#!/bin/bash

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -eo pipefail

# --- Log Helpers ---
# Usage: log "..."
log() {
  echo "[INFO] $*"
}

# Usage: error "..."
error() {
  echo "[ERROR] $*" >&2
  exit 1
}

# --- Prerequisite Functions ---
# Function to check if a command exists
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# --- Main Functions ---
# Function to install prerequisite packages
install_prerequisites() {
  log "Updating package lists..."
  if ! sudo apt-get update -y; then
    error "Failed to update package lists. Please check your internet connection and APT sources."
  fi

  log "Installing prerequisite packages..."
  if ! sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common wget; then
    error "Failed to install prerequisite packages."
  fi
}

# Function to install Docker
install_docker() {
  if command_exists docker; then
    log "Docker is already installed. Skipping installation."
    log "Docker version: $(docker --version)"
    return
  fi

  log "Installing Docker..."
  if ! sudo apt-get install -y docker.io; then
    error "Failed to install Docker."
  fi

  log "Starting and enabling Docker service..."
  if ! sudo systemctl start docker; then
    error "Failed to start Docker service."
  fi
  if ! sudo systemctl enable docker; then
    error "Failed to enable Docker service."
  fi

  log "Docker installed successfully."
  log "Docker version: $(docker --version)"
}

# Function to install Minikube
install_minikube() {
  if command_exists minikube; then
    log "Minikube is already installed. Skipping installation."
    log "Minikube version: $(minikube version)"
    return
  fi

  log "Downloading Minikube..."
  if ! wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O minikube; then
    error "Failed to download Minikube."
  fi

  log "Installing Minikube..."
  if ! sudo mv minikube /usr/local/bin/minikube; then
    error "Failed to move Minikube to /usr/local/bin."
  fi

  if ! sudo chmod +x /usr/local/bin/minikube; then
    error "Failed to make Minikube executable."
  fi

  log "Minikube installed successfully."
  log "Minikube version: $(minikube version)"
}

# Function to install kubectl
install_kubectl() {
  if command_exists kubectl; then
    log "kubectl is already installed. Skipping installation."
    log "kubectl version: $(kubectl version --client -o yaml)"
    return
  fi

  log "Downloading kubectl..."
  if ! curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"; then
    error "Failed to download kubectl."
  fi

  log "Installing kubectl..."
  if ! chmod +x kubectl; then
    error "Failed to make kubectl executable."
  fi

  if ! sudo mv kubectl /usr/local/bin/kubectl; then
    error "Failed to move kubectl to /usr/local/bin."
  fi

  log "kubectl installed successfully."
  log "kubectl version: $(kubectl version --client -o yaml)"
}

# Function to start Minikube
start_minikube() {
  log "Starting Minikube with the Docker driver..."
  if ! minikube start --driver=docker; then
    error "Failed to start Minikube. Please check your Docker installation and system resources."
  fi

  log "Checking Minikube status..."
  if ! minikube status; then
    error "Minikube is not running correctly."
  fi
}

# --- Main Execution ---
main() {
  install_prerequisites
  install_docker
  install_minikube
  install_kubectl
  start_minikube

  log "Installation and setup completed successfully!"
}

main
