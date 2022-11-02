#/bin/bash
####auther:ponishjino22@gmail.com################

#######Initial Server setup, SSH Hardening, Install LAMP stack#########
sudo hostnamectl set-hostname aidenjino.in
sudo apt-get update -y && apt-get upgrade -y
sudo apt-get install net-tools lynx unzip zip curl apache2 php awscli mysql-server mysql-client php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-mysql -y
sudo systemctl enable apache2
sudo useradd -p $(openssl passwd -1 Pass@2022) --shell /bin/bash jino
sudo mkdir /home/jino
sudo cp /root/.bashrc /home/jino
sudo chown -R jino:jino /home/jino
sudo systemctl restart apache2
sudo chmod 644 /etc/sudoers
sudo echo 'jino  ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
sudo sed -i 's/#Port 22/Port 1243/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/disable_root: true/disable_root: false/g' /etc/cloud/cloud.cfg
sudo echo "PermitRootLogin yes" >> /etc/ssh/sshd_config


#########Wordpress Files download ,Database config , Wordpress SALT& Apache #########
systemctl enable mysql
ip=`wget -qO - icanhazip.com`
install_dir="/var/www/html"
ip=`wget -qO - icanhazip.com`
db_name="wpdb"
db_user="wpuser"
db_password=`date |md5sum |cut -c '1-12'`
sleep 1
mysqlrootpass=`date |md5sum |cut -c '1-12'`
sleep 1
rm /var/www/html/index.html
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

