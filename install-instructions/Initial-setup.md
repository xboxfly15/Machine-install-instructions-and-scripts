---
---
###### UPDATED 2020.07.01
___
## Ubuntu:
Switch to root user
```
sudo su
```
Update packages:
```
apt-get update && apt-get upgrade
```
Create new user and set password to 30 long char with no symbol password
```
adduser <username>
```
Grant sudo privileges to the newly created user
```
usermod -aG sudo <username>
```
Set correct hostname for the machine - REFER TO SET HOSTNAME.TXT IF UNSURE  
Set correct timezone for the machines location - REFER TO SET TIMEZONE.TXT IF UNSURE  
Setup IPv6 - REFER TO SETUP IPV6.TXT IF UNSURE

Install lftp and zip for backups
```
apt-get install zip lftp -y
```
Install fail2ban:
```
apt-get install fail2ban -y
```
Exempt IP your IP from being banned:
```
nano /etc/fail2ban/jail.conf
```
Uncomment `ignoreip` and add your IP then restart fail2ban
```
systemctl restart fail2ban
```
If not already, switch to the newly created user
```
su <username>
```
If SSH key is not already setup
```
sudo mkdir ~/.ssh/
sudo nano ~/.ssh/authorized_keys
```
Input the countries SSH key   
Disable password authentication and root for SSH
```
sudo nano /etc/ssh/sshd_config
```
Change `PasswordAuthentication` from `yes` to `no`  
Change `PermitRootLogin` from `prohibit-password` to `no`  
Add `DenyUsers root ubuntu` to the bottom  
Save file and restart sshd
```
sudo systemctl restart sshd
```
Disable sudo password for SFTP
```
sudo visudo
```
Add this to the bottom of the file
```
<username> ALL=NOPASSWD: /usr/lib/openssh/sftp-server
```

Install GalaxyMC monitoring agent  
Install New Relic monitoring agent, remember to change `LICENSE_KEY_HERE` with your New Relic account license key
```
curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
echo "license_key: LICENSE_KEY_HERE
enable_process_metrics: true" | sudo tee -a /etc/newrelic-infra.yml
printf "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt focal main" | sudo tee -a /etc/apt/sources.list.d/newrelic-infra.list
sudo apt-get update && apt-get install newrelic-infra -y
```
Reboot for good measure
```
reboot now
```
DONE, you may now install the services