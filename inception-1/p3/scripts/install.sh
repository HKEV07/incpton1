apt-get update
apt-get install -y curl
curl -fsSL https://get.docker.com | sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash 2>/dev/null

usermod -aG docker dragon