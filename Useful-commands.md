###### UPDATED 2020.07.01
___
## Basic Ubuntu commands:
`df` shows disk usage, add -h to the end for human readable numbers  
`du` shows disk usage per files, add -h to the end of for human readable numbers, give it a directory and it will spit out the files in that directory and the size of those files  
`ls` lists everything in the directory that you are currently in or you can specify a directory  
`cd` to change directory  
`cd ~` to go to your home directory  
`cd /` to go to top most directory  
`cd ../` to go back a directory  
`mkdir` creates a directory  
`rm` deletes files + directories  
`touch` creates files  
`nano` is a text editor  
`cp` copies files  
`mv` moves files  
`cat` outputs whats in the file you specify  
`sudo` is superuser mode, all permissions - everything, you don't use this if you are using the root user as it already has all permissions but if you were using a user that wasn't root you'd use that  
`clear` clears the terminal  
`zip`, `unzip` and `gzip` do zippy things  
`uname -a` prints info about the machine like OS version, kernel version, hostname, datetime etc  
`chmod` changes the file/directory permissions, add -R to the end for it to change permissions for all files + directories in the directory you specify  
`chown` changes the owner/group permissions for file/directory, add -R to the end for it to change owner/group for all files + directories in the directory you specify  
`passwd` changes the password for the user you are currently logged into  
`su` switches user to the user you specify  
`whoami` outputs the name of the user you're currently logged into  
`ifconfig` outputs the network configuration  

#### There are also a few more basic commands like:
`grep`, `wget`, `curl`, `ping`, `traceroute`, `cron`, `find`, `tail`, `kill`, `uptime`


#### Looks for "string" inside of all files inside of "/path/"
`grep -rnw '/path/' -e 'string'`
#### Gets the size of files inside of "/path/", add "| sort -h" to the end for it to sort the output by largest file at the bottom
`du -sh /path/`

#### Screen commands:
Start session  
`screen -S <screen name>`
List sessions  
`screen -ls`
Detach from session  
`Ctrl + A` then press `D`
Attach to session  
`screen -r <screen name>`
To kill a session attached  
`Ctrl + A` then type `:quit`
To kill a session deattached  
`screen -X -S <screen name> quit`
To scroll in a session while attached  
`Ctrl + A` then press `ESC`, then use arrow keys for up and down or mouse scroll wheel, hit `Q` or `ESC` to stop scrolling
Ececute command detached  
`screen -S <screen name> -X eval 'stuff "COMMAND_HERE\015"'`
Writes everything in the scroll buffer to a file  
`Ctrl + A` then type `:hardcopy -h /path/FILE_NAME.txt`
