---
title: NodeJS Install
---
###### UPDATED 10.12.2020
___
Create new user just for running NodeJS, give it a nice strong password  
```
adduser nodejs
usermod -aG sudo nodejs
su nodejs
```
Download and install NodeJS 14  
```
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

mkdir /home/nodejs/projects
chmod 0700 /home/nodejs
chmod 0700 /home/nodejs/projects
```
Put all NodeJS projects/applications in /home/nodejs/projects - everything in that folder must have 0700 and nodejs owner/group  
```
sudo su -
npm install pm2 -g
```
If you're updating from an old version, node -v and nodejs -v may show different versions  
the reason it was like this FOR ME was because /usr/local/bin/node existed which was an old NodeJS binary, just delete it and relog SSH and they will show the same version  