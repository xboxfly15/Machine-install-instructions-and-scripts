---
title: HAProxy Install
---
```
add-apt-repository ppa:vbernat/haproxy-2.2
apt update && apt install haproxy -y
mkdir /etc/haproxy/certs/
```
Put SSL certificates into /etc/haproxy/certs/ - public keys suffixed with domain and .pem and private keys suffixed with domain and .pem.key
```
wget https://support.cloudflare.com/hc/en-us/article_attachments/360044928032/origin-pull-ca.pem > /etc/haproxy/cloudflare-origin-pull-ca.pem
nano /etc/haproxy/haproxy.cfg
```
Replace line 15 to 18 with
```
# See: https://ssl-config.mozilla.org/#server=haproxy&version=2.2.5&config=modern&openssl=1.1.1&guideline=5.6
ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
ssl-default-bind-options prefer-client-ciphers no-sslv3 no-tlsv10 no-tlsv11 no-tlsv12 no-tls-tickets

ssl-default-server-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
ssl-default-server-options no-sslv3 no-tlsv10 no-tlsv11 no-tlsv12 no-tls-tickets
```
Replace line 24 up to errorfile
```
mode http
option httplog
option dontlognull
option http-server-close
timeout http-request 5s
timeout connect 5s
timeout client 30s
timeout server 30s
timeout http-keep-alive 4s
```
Now add the sites below defaults section
```
listen domains
    bind *:80
    bind *:443 ssl strict-sni crt /etc/haproxy/certs verify required ca-file /etc/haproxy/cloudflare-origin-pull-ca.pem alpn h2,http/1.1
    redirect scheme https code 301 if !{ ssl_fc }
    option httpchk HEAD / HTTP/1.1
    http-check send hdr Host localhost

    # site example
    acl example_com hdr(host) -i example.com
    acl www_example_com hdr(host) -i www.example.com
    use-server 8000 if example_com
    use-server 8000 if www_example_com
    server 8000 127.0.0.1:8000

    # site example 2
    acl example_dev hdr(host) -i example.dev
    acl www_example_dev hdr(host) -i www.example.dev
    use-server 8001 if example_dev
    use-server 8001 if www_example_dev
    server 8001 127.0.0.1:8001

# Enables stats on http://127.0.0.1:79/
listen stats
   bind 127.0.0.1:79
   stats enable
   stats uri /
   stats realm Haproxy\ Statistics
```