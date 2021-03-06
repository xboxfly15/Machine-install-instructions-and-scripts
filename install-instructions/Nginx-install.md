###### UPDATED 02.04.2020
___
### 1. Install Nginx, PHP 7.4 and PHP 7.4 packages
```
add-apt-repository ppa:ondrej/php
add-apt-repository ppa:ondrej/nginx
apt-get update
apt-get install nginx nginx-common php7.4 php7.4-fpm php7.4-common php7.4-mysqli bzip2 php7.4-bz2 php7.4-zip php7.4-mbstring php7.4-curl -y
sudo update-alternatives --set php /usr/bin/php7.4
```
### 2. Delete default nginx sites
```
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
```
### 3. Setup nginx.conf, nginx catch-all site, SSL and nginx site conf(s)
#### (OPTIONAL) To add .php file support, add below to an nginx site file
```
# pass PHP scripts to FastCGI server
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
}
```
```
phpenmod mysqli
phpenmod zip
phpenmod bz2
phpenmod mbstring
phpenmod curl
```
EDIT /etc/nginx/nginx.conf and in http { change:
```
server_tokens off;
autoindex off;
```
(RECOMMENDED) To enable TLSv1.3 and disable TLSv1 TLSv1.1 change `ssl_protocols` to `TLSv1.2 TLSv1.3;`  
(OPTIONAL) If you're using CloudFlare - corrects IPs in log file and adds support for Nginx Amplify:  
```
# Logging Settings
log_format  main_ext  '$http_cf_connecting_ip - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for" '
                  '"$host" sn="$server_name" '
                  'rt=$request_time '
                  'ua="$upstream_addr" us="$upstream_status" '
                  'ut="$upstream_response_time" ul="$upstream_response_length" '
                  'cs=$upstream_cache_status' ;

access_log /var/log/nginx/access.log main_ext;
error_log /var/log/nginx/error.log warn;

set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 131.0.72.0/22;

set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2a06:98c0::/29;
set_real_ip_from 2c0f:f248::/32;

real_ip_header CF-Connecting-IP;
```
```
reboot now
```
## USEFUL COMMANDS:
To enable site: ln -s /etc/nginx/sites-available/SITE_NAME.conf /etc/nginx/sites-enabled/  
To disable site: rm -f /etc/nginx/sites-enabled/SITE_NAME.conf  
To set correct folder owner for website: chown www-data:www-data -R /var/www/SITE_DIRECTORY  
To restart Nginx: systemctl restart nginx  
To reload Nginx: systemctl reload nginx  

## ADDITIONAL LINKS:
https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/  
https://www.nginx.com/resources/wiki/start/topics/examples/full/  
https://www.nginx.com/resources/wiki/start/topics/recipes/cms_made_simple/  
https://www.nginx.com/resources/wiki/start/topics/examples/separateerrorloggingpervirtualhost/  

## OPTIONAL STUFF:
### To add static file cache:  
In an nginx site file add:  
```
location ~* \.(jpg|jpeg|png|gif|ico)$ {
    expires 30d;
}

location ~* \.(css|js)$ {
    expires 90d;
}
```

### Hide php settings:
EDIT /etc/php/7.4/fpm/php.ini
```
expose_php = Off
```
```
systemctl reload nginx
```
### Secure sensitive directories:
Let's say you have a Wordpress site and you want to block everyone but your external IP address and local LAN addresses from accessing wp-admin.  
Let's say your external IP address is 8.8.8.8 and your local LAN IP address scheme is 192.168.1.1/24.  
```
sudo nano /etc/nginx/sites-enabled/SITE_NAME.conf.
```
In the server {, add the following under the location / directive:
```
location /wp-admin {
  allow 192.168.1.1/24;
  allow 8.8.8.8;
  deny all;
}
```
```
systemctl reload nginx
```
Now if anyone tries to access wp-admin, they will be redirected to the 403 error page.

Limit the rate of requests:  
Say you want to limit the acceptance of incoming requests to wp-admin.  
To achieve this, we are going to use the limit_req_zone directory and configure a shared memory zone named one (which will store the requests for a specified key) and limit it to 30 requests per minute.  
For our specified key, we'll use the binary_remote_addr (which is a variable for the client/requesters IP address).  
```
sudo nano /etc/nginx/sites-enabled/SITE_NAME.conf
```
Above the server {, add the following line:
```
limit_req_zone $binary_remote_addr zone=one:10m rate=30r/m;
```
Scroll to where we added the wp-admin from `Secure sensitive directories`.  
Within that location, add the following line:  
```
limit_req zone=one;
```
So the wp-admin section might look like:  
```
location /wp-admin {
    allow 10.10.1.0/24;
    deny all;
    limit_req zone=one;
}
```
```
systemctl reload nginx
```
Your wp-admin will now only allow 30 requests per minute. After that 30th request, the user will see the following an error page.  
You can set that rate limit on any location that needs protecting by such a mechanism.