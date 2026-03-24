#!/bin/bash

# become root
sudo su 
cd ~

# Pull script from repo and make it executable
curl -fL -O https://raw.githubusercontent.com/robertrodriguezjr70/scripts/main/DockerContainerDownCheck.sh

chmod +x DockerContainerDownCheck.sh

#Modify crontab
(crontab -l 2>/dev/null; echo '* * * * * /bin/bash /root/DockerContainerDownCheck.sh') | crontab -

