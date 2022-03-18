---
---
```
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_8.4.4_amd64.deb
// Check md5sum equals 773367f803e7f6c5d094a41684ec3c63
sudo dpkg -i grafana_8.4.4_amd64.deb
sudo systemctl daemon-reload
sudo systemctl start grafana-server
```

Go to :3000, login with default credentials `admin:admin` and set new password
```
grafana-cli plugins install valiton-mongodbatlas-datasource
grafana-cli plugins install grafana-clock-panel
grafana-cli plugins install cloudspout-button-panel
grafana-cli plugins install flant-statusmap-panel

grafana-cli --pluginUrl https://github.com/yesoreyeram/grafana-infinity-datasource/archive/master.zip plugins install yesoreyeram-infinity-datasource
grafana-cli --pluginUrl https://github.com/yesoreyeram/grafana-newrelic-datasource/archive/master.zip plugins install yesoreyeram-newrelic-datasource
grafana-cli --pluginUrl https://github.com/valiton/grafana-mongodb-atlas-datasource/archive/master.zip plugins install valiton-mongodbatlas-datasource

service grafana-server restart
```
Setup SSL
```
sudo apt-get install certbot -y
```
Enter your email address for Let's Encrypt and the machines hostname/domain that will be used to connect to MySQL, this CANNOT be the machines IP address - add -d <domain> to add more domains to the SSL certificate
```
sudo certbot certonly --standalone --rsa-key-size 4096 --agree-tos -m <your email address> -d <full machine hostname>
```
Enter what you entered for <full machine hostname> in the certbot command to find the certificates that were generated so they can be moved to the correct grafana directory
```
sudo cat /etc/letsencrypt/live/<full machine hostname>/privkey.pem > /etc/grafana/private_key.pem
sudo cat /etc/letsencrypt/live/<full machine hostname>/fullchain.pem > /etc/grafana/public_key.pem
sudo cat /etc/letsencrypt/live/<full machine hostname>/chain.pem > /etc/grafana/ca.pem
```
Setup renewal for the certificates
```
sudo nano /home/renew-certbot-grafana.sh
```
Enter whats below into renew-certbot-grafana.sh - remember to change <full machine hostname> to what you entered in certbot command
```bash
#!/bin/bash
sudo cat /etc/letsencrypt/live/<full machine hostname>/privkey.pem > /etc/grafana/private_key.pem
sudo cat /etc/letsencrypt/live/<full machine hostname>/fullchain.pem > /etc/grafana/public_key.pem
chown -R root:grafana /etc/grafana/*.pem
systemctl restart grafana-server
```
```Make renew-certbot-grafana.sh executable
sudo chmod 744 /home/renew-certbot-grafana.sh
```
Setup a cron to run that script everyday at 00:00/12AM and 12:00/12PM
```
sudo crontab -e
```
Enter whats below to the bottom of crontab
```
0 0,12 * * * certbot renew --rsa-key-size 4096 --deploy-hook /home/renew-certbot-grafana.sh > /home/renew-certbot-grafana.log 2>&1
```

Change any settings
```
nano /etc/grafana/grafana.ini
```
Uncomment and change `protocol` to `https`  
Uncomment and change `enforce_domain` to `true`  
Uncomment and change `cert_file` to `/etc/grafana/public_key.pem`  
Uncomment and change `cert_key` to `/etc/grafana/private_key.pem`  
Uncomment and change `cookie_secure` to `true`  
Uncomment and change `strict_transport_security` to `true`  

Done, now setup data sources, plugins & dashboards

If you want Grafana to work on port 443, run:
```
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3000
sudo iptables-save
```