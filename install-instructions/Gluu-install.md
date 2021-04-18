---
---
Add the following to the bottom of /etc/security/limits.conf
```
* soft nofile 65535
* hard nofile 262144
```
Run `ulimit -n 262144` then `reboot now`  
Once the machine has restarted, run:
```
echo "deb https://repo.gluu.org/ubuntu/ focal main" > /etc/apt/sources.list.d/gluu-repo.list
curl https://repo.gluu.org/ubuntu/gluu-apt.key | apt-key add -
apt update && apt install gluu-server
apt-mark hold gluu-server

/sbin/gluu-serverd enable
/sbin/gluu-serverd start
/sbin/gluu-serverd login

cd /install/community-edition-setup
./setup.py
```
When you reach the "Select Services to Install"  
Select Oxd, Casa & Fido2

When asked whether you want to use Gluu storage for oxd  
Select yes

When you reach "Backend Install Options"  
Select Install OpenDJ locally

DONE, you may now sign into the site