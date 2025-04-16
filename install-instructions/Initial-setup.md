---
---

###### UPDATED 2025.04.18

___

## Ubuntu

Switch to root user

```bash
sudo su
```

Update packages:

```bash
apt-get update && apt-get upgrade
```

Create new user and set password to 30 long char with no symbol password

```bash
adduser <username>
```

Grant sudo privileges to the newly created user

```bash
usermod -aG sudo <username>
```

Set correct hostname for the machine - REFER TO SET HOSTNAME.TXT IF UNSURE  
Set correct timezone for the machines location - REFER TO SET TIMEZONE.TXT IF UNSURE  
Setup IPv6 - REFER TO SETUP IPV6.TXT IF UNSURE

Install lftp and zip for backups

```bash
apt-get install zip lftp -y
```

Install fail2ban:

```bash
apt-get install fail2ban -y
```

Exempt IP your IP from being banned:

```bash
nano /etc/fail2ban/jail.conf
```

Uncomment `ignoreip` and add your IP then restart fail2ban

```bash
systemctl restart fail2ban
```

If not already, switch to the newly created user

```bash
su YOUR_USERNAME
```

If SSH key is not already setup

```bash
sudo mkdir ~/.ssh/
sudo nano ~/.ssh/authorized_keys
```

Input the countries SSH key  
Disable password authentication and root for SSH

```bash
sudo nano /etc/ssh/sshd_config
```

Change `PasswordAuthentication` from `yes` to `no`  
Change `PermitRootLogin` from `prohibit-password` to `no`  
Add `DenyUsers root ubuntu` to the bottom  
Save file and restart sshd

```bash
sudo systemctl restart sshd
```

Disable sudo password for SFTP

```bash
sudo visudo
```

Add this to the bottom of the file

```bash
<username> ALL=NOPASSWD: /usr/lib/openssh/sftp-server
```

Install GalaxyMC monitoring agent  
Install New Relic monitoring agent, remember to change the environment variables

```bash
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash

sudo NEW_RELIC_API_KEY="NEW_RELIC_API_KEY" NEW_RELIC_ACCOUNT_ID="NEW_RELIC_ACCOUNT_ID" NEW_RELIC_REGION="NEW_RELIC_REGION" /usr/local/bin/newrelic install -y
```

Reboot for good measure

```bash
reboot now
```

DONE, you may now install the services
