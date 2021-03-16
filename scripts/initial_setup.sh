#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 3
fi

apt update -y && apt upgrade -y && apt autoremove -y

echo "Enter username"
read username
adduser $username
usermod -aG sudo $username

echo "Enter hostname"
read hostname
hostname -b $hostname
echo "$hostname" | sudo tee /etc/hostname

echo "Setting timezone to London"
timedatectl set-timezone Europe/London

echo "Enter network interface to enable IPv6"
read interface

echo "Enter IPv6 address"
read ipv6address

echo "Enter IPv6 prefix"
read ipv6prefix

echo "Enter IPv6 gateway"
read ipv6gateway

echo '
network:
    version: 2
    ethernets:
        '"$interface"':
            dhcp6: no
            match:
              name: '"$interface"'
            addresses:
              - "'"$ipv6address"'/'"$ipv6prefix"'"
            gateway6: "'"$ipv6gateway"'"
            routes:
              - to: "'"$ipv6gateway"'"
                scope: link
' | sudo -E tee /etc/netplan/51-cloud-init-ipv6.yaml >/dev/null 2>&1
netplan apply

echo "Installing zip, lftp & fail2ban"
apt-get install zip lftp fail2ban -y

echo "Enter the IP address you want ignored from fail2ban"
read ignoreip
sed -i 's/#ignoreip = 127.0.0.1/8 ::1/ignoreip = $ignoreip 127.0.0.1/8 ::1/' /etc/fail2ban/jail.conf

systemctl restart fail2ban

echo "Enter the SSH key for $username"
read sshkey
sudo mkdir /home/$username/.ssh/

echo "$sshkey" | sudo tee /home/$username/.ssh/authorized_keys
chown -R $username:$username /home/xboxfly15/.ssh/

echo "Disabling password authentication & root login"
sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
echo "Denying SSH login for root & ubuntu user"
echo "DenyUsers root ubuntu" | tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Disabling sudo password for SFTP $username"
echo "$username ALL=NOPASSWD: /usr/lib/openssh/sftp-server" | (EDITOR="tee -a" visudo)

# Install GalaxyMC monitoring agent - soon
echo "Installing New Relic monitoring agent, enter your license key"
read licensekey
curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
echo "license_key: $licensekey" | sudo tee -a /etc/newrelic-infra.yml
printf "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt focal main" | sudo tee -a /etc/apt/sources.list.d/newrelic-infra.list
sudo apt-get update && apt-get install newrelic-infra -y

echo "DONE!"
