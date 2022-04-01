#! /bin/bash

PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXGmP6L/zc9HsEKymjhSQS7mWjagPk7QVz25dcTNVOuAlMXewWyC7HpYmH+1Q9JvJcXwK3xpQYqzwBSNAUrQYHsRYl9K20b0vbmnZZWNsaVQNy+p5rcVhYCzqJZf0bXk95T6SR/51WAS8vJSYeJtbCYRTt5ar25y5KQ+O2PiBGC+77XJ+nbFaXJvSVjnR2RPzH1XhnOkZyWlcYVeLBk78kpwqkq5fX175pnvCYnXyCAhRL1Cn09a9OPQSCxpaxcgDdTsfZx45l9tOeN+5Zl8WYKmPZ1gC47KLTXN5T7W0LR6rOZlY4xOjQ+jiM/0cNeiTFkeS2G8+0nqK7aat8SXovM25FJPQNKj59ZAI++MguBsLn+4mreoEp8sA8GqwMbunFFtTPGSkBb16wj+GrOcJ8noPkEH96yB73FUrCxHNHC9/AToj9mutqqIiwc/8eBzlkyGUSKYs+j5JpPvpkAj6UCNclwbD6jkFGNKEqvbjCYlFMPtIVTwsml5GcICFMgg8= pwolthausen@duncan"

## Install nvidia drivers
apt update -y && apt upgrade -y
apt install nvidia-driver-510-server

## Install Open SSH
echo "Install and configure open SSH"
apt update -y
apt install -y openssh-server
curl -o /etc/ssh/sshd_config https://raw.githubusercontent.com/pwolthausen/filecoin/main/files/ssh_config
systemctl restart ssh


## Install Docker
echo "Installing Docker"
apt-get remove docker docker-engine docker.io containerd runc
apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io

## Install nvidia-docker
echo "Setting up NVIDIA Container Toolkit"
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update -y
apt-get install -y nvidia-docker2
systemctl restart docker

## Add lcoal users
echo "Adding local users for SSH"
useradd -m -s /bin/bash pwolthausen
groupadd -U pwolthausen,united vastAdmins
echo "%vastAdmins ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/vastAdmins
mkdir /home/pwolthausen/.ssh && chmod 700 /home/pwolthausen/.ssh && chown pwolthausen /home/pwolthausen/.ssh
echo $PUBLIC_KEY > /home/pwolthausen/.ssh/authorized_keys && chmod 600 /home/pwolthausen/.ssh/authorized_keys && chown pwolthausen /home/pwolthausen/.ssh/authorized_keys

## Install vast.io
apt install -y python2
wget https://vast.ai/install -O install; sudo python2.7 install 6429672403a2bb490a2115a57566e7fd84cf5f5b858828ae12d8e62da9b727ea; history -d $((HISTCMD-1)); 