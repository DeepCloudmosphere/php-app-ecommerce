#!/usr/bin/env bash

# ------------------------------------------------------------------------
# Simple bash script used to bootstrap ansible
#
# The following distros are supported:
#   - Fedora 20 and greater
#   - CentOS 7
#   - Ubuntu 16.04, 17.10, 18.04
#
# Brent WG
# 2018-02-27
# 2018-03-27
# ------------------------------------------------------------------------


# ----------------
# Script Functions
# ----------------
error_exit() {
  echo ""
  echo "$PRETTY_NAME is not supported by this script"
  echo
  exit 1
}

# ----------
# Get Distro
# ----------
echo ""
echo "Getting OS version..."
. /etc/os-release

# ---------------
# Install Ansible
# ---------------
echo ""
echo "Installing Ansible for: $PRETTY_NAME..."
## Deal with Fedora (version 20 and greater)
if [ "$ID" == "fedora" ]; then
  ## Use dnf > 21
  if [ $VERSION_ID -gt 21 ]; then
    echo "Using: sudo dnf install -y ansible"
    sudo dnf install -y ansible
  ## Use yum for 20 - 21
  elif [ $VERSION_ID -eq 20 ] || [ $VERSION_ID -eq 21 ]; then
    echo "Using: sudo yum -y install ansible"
    sudo yum -y install ansible
  else
    error_exit
  fi
fi

## Deal with CentOS 7
if [ "$ID" == "centos" ]; then
  if [ $VERSION_ID -eq 7 ]; then
    echo "Installing EPEL and Ansible"
    sudo yum install -y epel-release
    sudo yum install -y ansible
  else
    error_exit
  fi
fi

## Deal with Ubuntu
if [ "$ID" == "ubuntu" ]; then
  case "$VERSION_ID" in
    16.04|17.10)
      echo "Adding PPA, then installing Ansible"
      sudo apt-add-repository ppa:ansible/ansible -y
      sudo apt-get update
      sudo apt-get install software-properties-common ansible python-apt -y
      ;;
    18.04|22.04)
      echo "Importing Ansible signing keys"
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
      echo "Adding Ansible PPA, then installing Ansible"
      sudo apt-add-repository "deb http://ppa.launchpad.net/ansible/ansible/ubuntu artful main" -y
      sudo apt-get update
      sudo apt-get install ansible -y
      ;;
    *)
      error_exit
      ;;
  esac
fi



# download private key

aws secretsmanager get-secret-value --secret-id jenkins --region us-east-1 | python3 -c "import sys;import json;print(json.loads(json.loads(sys.stdin.read())['SecretString'])['private'])" > /home/ubuntu/.ssh/jenkins

# remove ' in jenkins key

sed -i "s/'//g" /home/ubuntu/.ssh/jenkins

# change ownership of key

chown ubuntu: /home/ubuntu/.ssh/jenkins

# create ansible configuration file to ignore host_key_checking

cat << EOT > ansible.cfg
[defaults]
host_key_checking = False
EOT


# create inventory file in current directory

cat << EOT > inventory.txt 
jenkins ansible_host=192.168.64.50 ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/jenkins
EOT


# add hostname in /etc/hosts file

sed -i '/^127\.0\.0\.1\s/s/$/ '"ansible-controller"'/' /etc/hosts

# add hostname in /etc/hostname file

hostnamectl set-hostname ansible-controller


# reboot

shutdown -r now