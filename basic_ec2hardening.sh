#/bin/bash
sudo hostnamectl set-hostname elson-devops.com
sudo apt-get update -y && apt-get upgrade -y
sudo apt-get install net-tools lynx curl apache2 telnet inetutils-traceroute awscli -y
sudo systemctl enable apache2
sudo useradd -p $(openssl passwd -1 Pass@2022) --shell /bin/bash elson
sudo mkdir /home/elson
sudo cp /root/.bashrc /home/elson
sudo chown -R elson:elson /home/elson
sudo systemctl restart apache2
sudo chmod 644 /etc/sudoers
sudo echo 'elson  ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
sudo sed -i 's/#Port 22/Port 1243/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/disable_root: true/disable_root: false/g' /etc/cloud/cloud.cfg
sudo echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sudo service ssh restart && sudo service ssh restart
