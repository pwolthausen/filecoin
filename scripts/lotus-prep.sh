#! /bin/bash

PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXGmP6L/zc9HsEKymjhSQS7mWjagPk7QVz25dcTNVOuAlMXewWyC7HpYmH+1Q9JvJcXwK3xpQYqzwBSNAUrQYHsRYl9K20b0vbmnZZWNsaVQNy+p5rcVhYCzqJZf0bXk95T6SR/51WAS8vJSYeJtbCYRTt5ar25y5KQ+O2PiBGC+77XJ+nbFaXJvSVjnR2RPzH1XhnOkZyWlcYVeLBk78kpwqkq5fX175pnvCYnXyCAhRL1Cn09a9OPQSCxpaxcgDdTsfZx45l9tOeN+5Zl8WYKmPZ1gC47KLTXN5T7W0LR6rOZlY4xOjQ+jiM/0cNeiTFkeS2G8+0nqK7aat8SXovM25FJPQNKj59ZAI++MguBsLn+4mreoEp8sA8GqwMbunFFtTPGSkBb16wj+GrOcJ8noPkEH96yB73FUrCxHNHC9/AToj9mutqqIiwc/8eBzlkyGUSKYs+j5JpPvpkAj6UCNclwbD6jkFGNKEqvbjCYlFMPtIVTwsml5GcICFMgg8= pwolthausen@duncan"

apt update -y && apt upgrade -y
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

## Install Nvidia drivers
apt-get purge -y '*nvidia*'
apt-get purge -y '*libnvidia*'
apt-get purge -y '*cuda*'
apt autoremove -y
add-apt-repository ppa:graphics-drivers/ppa --yes
apt update
apt install -y nvidia-driver-460-server

## Configure Open SSH
echo "Install and configure open SSH"
curl -o /etc/ssh/sshd_config https://raw.githubusercontent.com/pwolthausen/filecoin/main/files/ssh_config
systemctl restart ssh

## Add lcoal users
echo "Adding local users for SSH"
useradd -m -s /bin/bash pwolthausen
groupadd filecoinAdmins
usermod -G filecoinAdmins pwolthausen
echo "%filecoinAdmins ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/filecoinAdmins
mkdir /home/pwolthausen/.ssh && chmod 700 /home/pwolthausen/.ssh && chown pwolthausen /home/pwolthausen/.ssh
echo $PUBLIC_KEY > /home/pwolthausen/.ssh/authorized_keys && chmod 600 /home/pwolthausen/.ssh/authorized_keys && chown pwolthausen /home/pwolthausen/.ssh/authorized_keys

groupadd render
useradd -m -s /bin/bash -G render filecoin

## Create lotus directories
LOTUSDIR=("lotus" ".lotus" ".lotusminer" ".lotusworker-pc1" "lotusworker-pc2" "lotusworker-commit" "lotusworker-ap")
for dir in $LOTUSDIR
  do
    mkdir -p /opt/$dir
    chown filecoin:filecoin /opt/$dir
  done

for dir in "node" "sealing0" "sealing1"
  do
    mkdir -p /opt/lotus/$dir
    chown filecoin:filecoin /opt/lotus/$dir
  done

## Prepare Lotus app
apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget -y && sudo apt upgrade -y

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

apt purge golang*
wget -c https://golang.org/dl/go1.16.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/go/bin"'

git clone https://github.com/filecoin-project/lotus.git /opt/lotus/lotus
make -C /opt/lotus/lotus clean all
make -C /opt/lotus/lotus install

## Clean up
apt update && apt upgrade -y
apt autoremove -y
reboot now
