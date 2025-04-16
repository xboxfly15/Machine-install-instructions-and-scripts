#!/usr/bin/bash

set -e

bunnycdn_ips() {
	echo "# Accepts request from defined IP"
	echo "# https://bunnycdn.com/api/system/edgeserverlist/plain"
	echo "# Generated at $(LC_ALL=C date)"

	echo '
http:
  middlewares:
    bunny-allowlist:
      ipWhiteList:
        sourceRange:'

    curl -sL "https://bunnycdn.com/api/system/edgeserverlist/plain" | sed "s/\r//g" | sed "s|^|          - \"|g" | sed "s|\$|\"|g"
	# Echo to add new line at end of file
	# echo
}

bunnycdn_ips > /home/allow_bunnycdn_only-temp.yaml

# Move file once finished to not cause unexpected end of stream in Traefik dynamic configurations
mv /home/allow_bunnycdn_only-temp.yaml /data/coolify/proxy/dynamic/allow_bunnycdn_only.yaml