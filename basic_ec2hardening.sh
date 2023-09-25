#/bin/bash
####auther:elsonpulikkan@gmail.com################

#######Initial Server , SSH Setup, Install APache#########
sudo hostnamectl set-hostname mywp.com
ip=`wget -qO - icanhazip.com`
username="elson"
random_password=$(openssl rand -base64 12)
sudo useradd -m -s /bin/bash "$username"
echo "$username:$random_password" | sudo chpasswd
sudo mkdir /home/elson
sudo cp /root/.bashrc /home/elson
sudo chown -R elson:elson /home/elson
sudo chmod 644 /etc/sudoers
sudo echo 'elson  ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
sudo sed -i 's/#Port 22/Port 1243/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/disable_root: true/disable_root: false/g' /etc/cloud/cloud.cfg
#sudo echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sudo echo "ClientAliveInterval 3600" >> /etc/ssh/ssh_config
sudo echo "ServerAliveCountMax=2" >> /etc/ssh/ssh_config
sudo systemctl restart ssh
sudo systemctl restart sshd
sudo apt-get update -y && apt-get upgrade -y
sudo apt-get install net-tools lynx unzip zip curl apache2 -y 
sudo systemctl enable apache2
sudo systemctl status apache2
sudo cat /dev/null > /var/www/html/index.html

####### Adds a custom html page to the default httpd page #########

orumairan=$(cat <<EOF
<!DOCTYPE html>
<html>
    <h1>It Works.! oru-mairan.com</h1>

<head>
    <meta charset="UTF-8">
    <title>Tears of Joy</title>
    <style>
        /* Add some CSS to style the emoji */
        .tears-of-joy {
            font-size: 48px;
            color: #00BFFF; /* Change the color as desired */
        }
    </style>
</head>
<body>
    <div class="tears-of-joy">&#128514;</div>
</body>
</html>
EOF
)
sudo echo "$orumairan" > /var/www/html/index.html
sudo systemctl restart apache2
echo "User '$elson' created on the server with random password: $random_password"
sudo printf "\n"
sudo echo "If you're a human, Try login SSH by the following command :  ssh elson@$ip -p1243"
sudo printf "\n"
sudo printf "Paste this Pub. IP address on your browser to see oru-marian.com : \n\n http://$ip\n\n"
