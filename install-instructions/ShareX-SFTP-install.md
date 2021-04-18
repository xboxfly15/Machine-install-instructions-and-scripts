---
title: ShareX SFTP Install
---
```
adduser sharex
mkdir -p /home/sftp/uploads
chmod 0777 /home/sftp/uploads
ln -s /home/sftp/uploads/ /home/nodejs/projects/node_sharex-images/
nano /etc/ssh/sshd_config
```
Add to bottom
```
Match User sharex
  PasswordAuthentication yes
  # Force the connection to use SFTP and chroot to the required directory.
  ForceCommand internal-sftp
  ChrootDirectory /home/sftp/
  # Disable tunneling, authentication agent, TCP and X11 forwarding.
  PermitTunnel no
  AllowAgentForwarding no
  AllowTcpForwarding no
  X11Forwarding no
  ```