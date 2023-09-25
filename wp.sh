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
sudo echo "ServerAliveInterval 3600" >> /etc/ssh/ssh_config
sudo echo "ServerAliveCountMax=2" >> /etc/ssh/ssh_config
systemctl restart ssh
systemctl restart sshd
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
sudo printf "Paste this Pub. IP address on your browser to login oru-marian.com : \n\n http://$ip\n\n"



#########Wordpress + LAMP  Files download ,Database config , Wordpress SALT& Apache restart #########
sudu rm -rf /var/www/html/index.html
sudo apt-get install php php8.1-fpm awscli mysql-server mysql-client php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-mysql -y
systemctl enable mysql
install_dir="/var/www/html"
ip=`wget -qO - icanhazip.com`
db_name="wpdb"
db_user="wpuser"
db_password=`date |md5sum |cut -c '1-12'`
sleep 1
mysqlrootpass=`date |md5sum |cut -c '1-12'`
sleep 1
echo "Downloading WordPress"
cd /tmp/ && wget "http://wordpress.org/latest.tar.gz";
/bin/tar -C $install_dir -zxf /tmp/latest.tar.gz --strip-components=1
mv $install_dir/wp-config-sample.php $install_dir/wp-config.php
sed -i s/database_name_here/$db_name/g $install_dir/wp-config.php
sed -i s/username_here/$db_user/g $install_dir/wp-config.php
sed -i s/password_here/$db_password/g $install_dir/wp-config.php
cat << EOF >> $install_dir/wp-config.php
define('FS_METHOD', 'direct');
EOF
grep -A50 'table_prefix' $install_dir/wp-config.php > /tmp/wp-tmp-config
/bin/sed -i '/**#@/,/$p/d' $install_dir/wp-config.php
/usr/bin/lynx --dump -width 200 https://api.wordpress.org/secret-key/1.1/salt/ >> $install_dir/wp-config.php
/bin/cat /tmp/wp-tmp-config >> $install_dir/wp-config.php && rm /tmp/wp-tmp-config -f
/usr/bin/mysql -e "USE mysql;"
/usr/bin/mysql -e "ALTER USER root@localhost IDENTIFIED BY '$mysqlrootpass';"
/usr/bin/mysql -e "CREATE DATABASE $db_name;"
/usr/bin/mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';"
/usr/bin/mysql -e "GRANT ALL ON *.* TO '$db_user'@'localhost';"
/usr/bin/mysql -e "FLUSH PRIVILEGES;"
sudo find $install_dir -type d -exec chmod 755 {} \;
sudo find $install_dir -type f -exec chmod 644 {} \;
sudo chown -R www-data:www-data $install_dir
sudo systemctl restart apache2 && sudo systemctl restart mysql
sudo service ssh restart && sudo service ssh restart


######Display generated passwords to the user #########
printf "New Wordpress Database Name:\n\n $db_name\n" 
printf "New Wordpress Database User:\n\n $db_user\n"
printf "New WP Database User Password:\n\n $db_password\n"
printf "Mysql root password:\n\n" $mysqlrootpass\n
printf "Copy paste this Wordpress login URL on a Web Browser : \n\n http://$ip\n\n"
