---
title: MongoDB Install
---
###### UPDATED 2020.07.01
___
## Ubuntu 20.04:
Install certbot for MongoDB SSL  
```
sudo apt-get install certbot -y
```
Enter your email address for Let's Encrypt and the machines hostname/domain that will be used to connect to MongoDB, this CANNOT be the machines IP address - add -d <domain> to add more domains to the SSL certificate  
```
sudo certbot certonly --standalone --rsa-key-size 4096 --agree-tos -m <your email address> -d <full machine hostname>
```
Enter what you entered for <full machine hostname> in the certbot command to find the certificates that were generated so they can be converted to a .pem file  
```
sudo cat /etc/letsencrypt/live/<full machine hostname>/fullchain.pem /etc/letsencrypt/live/<full machine hostname>/privkey.pem > /etc/ssl/mongodb.pem
sudo chmod 644 /etc/ssl/mongodb.pem
```
Setup renewal for the certificates  
```
sudo touch /home/renew-certbot-mongodb.sh
sudo nano /home/renew-certbot-mongodb.sh
```
Enter whats below into renew-certbot-mongodb.sh - remember to change <full machine hostname> to what you entered in certbot command  
```
#!/bin/bash
cat /etc/letsencrypt/live/<full machine hostname>/fullchain.pem /etc/letsencrypt/live/<full machine hostname>/privkey.pem > /etc/ssl/mongodb.pem
chmod 644 /etc/ssl/mongodb.pem
chown -R mongodb:mongodb /etc/ssl/mongodb.pem
service mongod restart
```
Make renew-certbot-mongodb.sh executable  
```
sudo chmod 744 /home/renew-certbot-mongodb.sh
```
Setup a cron to run that script every every day at 00:00/12AM and 12:00/12PM  
```
sudo crontab -e
```
Enter whats below to the bottom of crontab  
```
0 0,12 * * * certbot renew --quiet --rsa-key-size 4096 --deploy-hook /home/renew-certbot-mongodb.sh > /home/renew-certbot-mongodb.log 2>&1
```
#### Optimizations for MongoDB
Set readahead to 32 as per https://docs.mongodb.com/manual/administration/production-notes/#readahead - remember to change the location to your partition where MongoDB data will be stored  
```
blockdev --setra 32 /dev/sda1
```
Set disk schedulers to noop for SSD drives as per https://docs.mongodb.com/manual/administration/production-checklist-operations/#linux
```
sudo nano /etc/default/grub  
```
Add `,elevator=noop` to the end of `defaults` for the partition where MongoDB data will be stored  
Enable noatime for the partiton where MongoDB data will be stored as per https://docs.mongodb.com/manual/administration/production-checklist-operations/#linux  
```
sudo nano /etc/fstab
```
Add `,noatime` to the end of `defaults` for the partition where MongoDB will be stored  
Disable transparent hude pages per https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/  
```
sudo touch /etc/systemd/system/disable-transparent-huge-pages.service
sudo nano /etc/systemd/system/disable-transparent-huge-pages.service
```
Add whats below to disable-transparent-huge-pages.service  
```
[Unit]
Description=Disable Transparent Huge Pages (THP)
DefaultDependencies=no
After=sysinit.target local-fs.target
Before=mongod.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null'

[Install]
WantedBy=basic.target
```

Reload systemctl and enable the service  
```
sudo systemctl daemon-reload
sudo systemctl start disable-transparent-huge-pages
sudo systemctl enable disable-transparent-huge-pages
```
Install MongoDB 4.4 via tar, extract, move the executables to /usr/bin, create new user for mongodb and set file permissions to directories/files that MongoDB will use  
```
sudo apt install libcurl4 openssl
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-4.4.0.tgz
tar -zxvf mongodb-linux-*.tgz
sudo cp mongodb-linux-*/bin/* /usr/local/bin/
sudo rm -R mongodb-linux-*
```
The directory that MongoDB will store the database files, edit to your liking  
```
sudo mkdir -p /var/lib/mongo
sudo mkdir -p /var/log/mongodb
sudo useradd mongodb
sudo chown -R mongodb:mongodb /usr/local/bin/mongo
sudo chown -R mongodb:mongodb /usr/local/bin/mongod
sudo chown -R mongodb:mongodb /usr/local/bin/mongos
```
The directory that MongoDB will store the database files, edit to your liking  
```
sudo chown -R mongodb:mongodb /var/lib/mongo
sudo chown -R mongodb:mongodb /var/log/mongodb
```

Create MongoDB configuration file  
```
sudo touch /etc/mongod.conf
sudo nano /etc/mongod.conf
```
Enter whats below into mongod.conf - remember to edit storage.dbPath to your liking
DO NOT edit net.bindIpAll, net.tls.mode or security.authorization! That will be changed later to enable remote connections, TLS and authorization
```
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# Where and how to store data.
storage:
  dbPath: /var/lib/mongo
  journal:
    enabled: true
#  engine:
#  wiredTiger:

# how the process runs
processManagement:
  fork: false
  pidFilePath: /var/run/mongodb/mongod.pid  # location of pidfile
  timeZoneInfo: /usr/share/zoneinfo

# network interfaces
net:
  port: 27017
  ipv6: true
  bindIpAll: false
  tls:
    mode: preferTLS
    certificateKeyFile: /etc/ssl/mongodb.pem

security:
  authorization: disabled

#operationProfiling:

#replication:

#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:
```

Create MongoDB service that will start MongoDB on machine startup  
```
sudo touch /etc/systemd/system/mongodb.service
sudo nano /etc/systemd/system/mongodb.service
```
Enter whats below into mongodb.service  
```
#Unit contains the dependencies to be satisfied before the service is started.
[Unit]
Description=MongoDB Database
After=network.target
Documentation=https://docs.mongodb.org/manual
# Service tells systemd, how the service should be started.
# Key `User` specifies that the server will run under the mongodb user and
# `ExecStart` defines the startup command for MongoDB server.
[Service]
User=mongodb
Group=mongodb
ExecStart=/usr/local/bin/mongod --quiet --config /etc/mongod.conf
ExecStartPre=mkdir -p /var/run/mongodb
ExecStartPre=chown mongodb:mongodb /var/run/mongodb
ExecStartPre=chmod 0755 /var/run/mongodb
PermissionsStartOnly=true
PIDFile=/run/mongodb/mongod.pid
# (file size)
LimitFSIZE=infinity
# (cpu time)
LimitCPU=infinity
# (virtual memory size)
LimitAS=infinity
# (locked-in-memory size)
LimitMEMLOCK=infinity
# (open files)
LimitNOFILE=64000
# (processes/threads)
LimitNPROC=64000
# Install tells systemd when the service should be automatically started.
# `multi-user.target` means the server will be automatically started during boot.
[Install]
WantedBy=multi-user.target
```

Reload systemctl, start MongoDB and enable MongoDB to start on machine startup  
```
sudo systemctl daemon-reload
sudo systemctl start mongodb
sudo systemctl status mongodb
sudo systemctl enable mongodb
```
Setup fail2ban to block 3 failed login attempts to MongoDB  
```
sudo nano /etc/fail2ban/jail.local
```
Enter whats below into jail.local  
```
[mongo-auth]
enabled = true
filter  = mongo-auth
logpath = /var/log/mongodb/mongod.log
maxretry = 3
port    = 27017
banaction = iptables-multiport[name="mongo", port="27017"]
```

Restart fail2ban  
```
sudo systemctl restart fail2ban
```
Connect to MongoDB, switch to admin database, create an admin user and enable free monitoring - remember to change <admin username> and <admin password> to your liking  
```
mongo
use admin
db.createUser({user:"<admin username>", pwd:"<admin password>", roles:[{role:"root", db:"admin"}, "readWriteAnyDatabase"]})
db.enableFreeMonitoring()
exit
```
Now that you've created an admin user, remote connections, TLS required and authorization can be enabled  
```
sudo nano /etc/mongod.conf
```
Update the values below in mongod.conf  
```
net.bindIpAll: true
net.tls.mode: requireTLS
security.authorization: enabled
```
Restart MongoDB, make sure it starts and if it does, reboot the machine  
```
sudo systemctl restart mongodb
sudo reboot now
```
Once the reboot is done and everything has started and is working, you're DONE!  
Useful website to learn MongoDB commands: https://docs.mongodb.com/manual/tutorial/getting-started/#getting-started  

I used these sites to research and make this instruction, credit to them  
https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu-tarball/  
https://docs.mongodb.com/manual/release-notes/4.4-upgrade-standalone/  
https://docs.mongodb.com/manual/reference/program/mongod/  
https://docs.mongodb.com/manual/tutorial/  
https://docs.mongodb.com/manual/storage/  
https://docs.mongodb.com/manual/administration/security-checklist/  
https://docs.mongodb.com/manual/reference/configuration-options/  
https://docs.mongodb.com/manual/administration/production-checklist-operations/  
https://docs.mongodb.com/manual/administration/free-monitoring/  
https://opensource.com/article/20/6/linux-noatime  
https://bekce.github.io/securing-mongodb-tls-auth-letsencrypt/  
https://certbot.eff.org/docs/using.html?highlight=hooks#renewing-certificates  
https://askubuntu.com/questions/78682/how-do-i-change-to-the-noop-scheduler  
https://www.digitalocean.com/community/tutorials/how-to-install-mongodb-on-ubuntu-18-04  
https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-mongodb-on-ubuntu-16-04#part-two-securing-mongodb  
https://hevodata.com/blog/install-mongodb-on-ubuntu/  
https://stackoverflow.com/questions/21954080/how-to-install-mongodb-binary-package-on-linux  
https://insights-core.readthedocs.io/en/latest/shared_parsers_catalog/mongod_conf.html  
https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/  
https://docs.mongodb.com/manual/administration/analyzing-mongodb-performance/  
https://www.howtoforge.com/how-to-manage-lets-encrypt-ssl-tls-certificates-with-certbot/  
https://docs.mongodb.com/manual/tutorial/configure-ssl/#procedures-using-net-tls-settings  
https://docs.mongodb.com/manual/tutorial/enable-authentication/  
https://jira.mongodb.org/browse/SERVER-27241  
https://github.com/mongodb/mongo/commit/e7a503b2b993a387a52133ad37e8976e9cd2ab07  
