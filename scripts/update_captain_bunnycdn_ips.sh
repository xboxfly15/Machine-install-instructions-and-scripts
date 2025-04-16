#!/usr/bin/bash

set -e

bunnycdn_ips() {
	echo "# https://bunnycdn.com/api/system/edgeserverlist/plain"
	echo "# Generated at $(LC_ALL=C date)"

        curl -sL "https://bunnycdn.com/api/system/edgeserverlist/plain" | sed "s/\r//g" | sed "s|^|allow |g" | sed "s|\$|;|g"
	echo
}

(bunnycdn_ips && echo "deny all; # deny all remaining ips") > /captain/data/nginx-shared/allow_bunnycdn_only.conf

# reload Nginx
docker exec -t $(docker container ls -q --filter name=captain-nginx.*) nginx -s reload
