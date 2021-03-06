#! /bin/bash

PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXGmP6L/zc9HsEKymjhSQS7mWjagPk7QVz25dcTNVOuAlMXewWyC7HpYmH+1Q9JvJcXwK3xpQYqzwBSNAUrQYHsRYl9K20b0vbmnZZWNsaVQNy+p5rcVhYCzqJZf0bXk95T6SR/51WAS8vJSYeJtbCYRTt5ar25y5KQ+O2PiBGC+77XJ+nbFaXJvSVjnR2RPzH1XhnOkZyWlcYVeLBk78kpwqkq5fX175pnvCYnXyCAhRL1Cn09a9OPQSCxpaxcgDdTsfZx45l9tOeN+5Zl8WYKmPZ1gC47KLTXN5T7W0LR6rOZlY4xOjQ+jiM/0cNeiTFkeS2G8+0nqK7aat8SXovM25FJPQNKj59ZAI++MguBsLn+4mreoEp8sA8GqwMbunFFtTPGSkBb16wj+GrOcJ8noPkEH96yB73FUrCxHNHC9/AToj9mutqqIiwc/8eBzlkyGUSKYs+j5JpPvpkAj6UCNclwbD6jkFGNKEqvbjCYlFMPtIVTwsml5GcICFMgg8= pwolthausen@duncan"
NVIDIA_DEVICE=$(lspci | awk '$2 == "VGA" {print $8}')

apt update -y && apt upgrade -y
apt install -y python2 openssh-server vim

## Install Nvidia drivers
apt-get purge -y '*nvidia*'
apt-get purge -y '*libnvidia*'
apt-get purge -y '*cuda*'
apt autoremove -y
add-apt-repository ppa:graphics-drivers/ppa --yes
apt update
apt install -y nvidia-driver-510-server

# if [[ $NVIDIA_DEVICE == *"2204"* ]]; then
#   echo "Setting env var for 3090"
#   echo 'DISPLAY=:0 XAUTHORITY=/var/run/lightdm/root/:0 /usr/bin/nvidia-settings --assign "[gpu:0]/GPUGraphicsClockOffset[3]=-200" --assign "[gpu:0]/GPUMemoryTransferRateOffset[3]=2400" --assign "[gpu:1]/GPUGraphicsClockOffset[3]=-200" --assign "[gpu:1]/GPUMemoryTransferRateOffset[3]=2400"' >> /etc/environment
# fi
# if [[ $NVIDIA_DEVICE == *"2484"* ]]; then
#   echo "Setting env var for 3070"
#   echo 'DISPLAY=:0 XAUTHORITY=/var/run/lightdm/root/:0 /usr/bin/nvidia-settings --assign "[gpu:0]/GPUGraphicsClockOffset[3]=-100" --assign "[gpu:0]/GPUMemoryTransferRateOffset[3]=2800" --assign "[gpu:1]/GPUGraphicsClockOffset[3]=-100" --assign "[gpu:1]/GPUMemoryTransferRateOffset[3]=2800"' >> /etc/environment
# fi

## Configure Open SSH
echo "Install and configure open SSH"
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
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

## Install nvidia-docker
echo "Setting up NVIDIA Container Toolkit"
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update
apt-get install -y nvidia-docker2
systemctl restart docker

## Add lcoal users
echo "Adding local users for SSH"
useradd -m -s /bin/bash pwolthausen
groupadd vastAdmins
usermod -G vastAdmins pwolthausen
echo "%vastAdmins ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/vastAdmins
mkdir /home/pwolthausen/.ssh && chmod 700 /home/pwolthausen/.ssh && chown pwolthausen /home/pwolthausen/.ssh
echo $PUBLIC_KEY > /home/pwolthausen/.ssh/authorized_keys && chmod 600 /home/pwolthausen/.ssh/authorized_keys && chown pwolthausen /home/pwolthausen/.ssh/authorized_keys

## Clean up
apt update && apt upgrade -y
apt autoremove -y
reboot now
