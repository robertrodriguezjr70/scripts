#!/bin/bash

cd /root || exit 1
curl -fL -O https://raw.githubusercontent.com/robertrodriguezjr70/scripts/main/DockerContainerDownCheck.sh
chmod +x /root/DockerContainerDownCheck.sh
(crontab -l 2>/dev/null; echo '* * * * * /bin/bash /root/DockerContainerDownCheck.sh') | crontab -
