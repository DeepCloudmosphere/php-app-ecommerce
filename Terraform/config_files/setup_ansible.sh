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

## for ubuntu
aws secretsmanager get-secret-value --secret-id jenkins --region us-east-1 | python3 -c "import sys;import json;print(json.loads(json.loads(sys.stdin.read())['SecretString'])['private'])" > /home/ubuntu/.ssh/jenkins
## for root
aws secretsmanager get-secret-value --secret-id jenkins --region us-east-1 | python3 -c "import sys;import json;print(json.loads(json.loads(sys.stdin.read())['SecretString'])['private'])" > ~/.ssh/jenkins

# remove ' in jenkins key

sed -i "s/'//g" /home/ubuntu/.ssh/jenkins

# root
sed -i "s/'//g" ~/.ssh/jenkins

# change ownership of key

chown ubuntu: /home/ubuntu/.ssh/jenkins
# root
chown root: ~/.ssh/jenkins

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





# setup keys 

mkdir ssh_keys && cd ssh_keys 

# download private and public  key for authentication at the time of ci/cd


aws secretsmanager get-secret-value --secret-id jenkins --region us-east-1 | python3 -c "import sys;import json;print(json.loads(json.loads(sys.stdin.read())['SecretString'])['private'])" > jenkins.key

aws secretsmanager get-secret-value --secret-id jenkins --region us-east-1 | python3 -c "import sys;import json;print(json.loads(json.loads(sys.stdin.read())['SecretString'])['public'])" > jenkins.pem

aws secretsmanager get-secret-value --secret-id ansible --region us-east-1 | python3 -c "import sys;import json;print(json.loads(json.loads(sys.stdin.read())['SecretString'])['private'])" > ansible.key


# remove ' in the keys

sed -i "s/'//g" jenkins.key
sed -i "s/'//g" jenkins.pem
sed -i "s/'//g" ansible.key



# change ownership of key

chown ubuntu: jenkins.key
chown ubuntu: jenkins.pem
chown ubuntu: ansible.key

# create github configuration file to authenticate it

# for ubuntu
cat << EOT > /home/ubuntu/.ssh/config 
Host github.com
 HostName github.com
 IdentityFile /home/ubuntu/.ssh/jenkins
EOT

# for root
cat << EOT > ~/.ssh/config 
Host github.com
 HostName github.com
 IdentityFile ~/.ssh/jenkins
EOT


# the permissions on your IdentityFile must 400 otherwise SSH will reject, in a not clearly explicit manner, SSH keys that are too readable. It will just look like a credential rejection.

chmod 400 /home/ubuntu/.ssh/jenkins
# root
chmod 400 ~/.ssh/jenkins


# change permision of config file
chmod 600 /home/ubuntu/.ssh/config
# root
chmod 600 ~/.ssh/config



# change ownership of file of ubuntu user

chown ubuntu: /home/ubuntu/.ssh/config

chown ubuntu: /home/ubuntu/.ssh/jenkins

# change ownership of file of root user

chown root: ~/.ssh/config

chown root: ~/.ssh/jenkins




# reboot

shutdown -r now