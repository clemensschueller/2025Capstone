#!/bin/bash

# Update system packages
sudo yum update -y

# Install httpd (webserver), start and enable it
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd

# Install MariaDB, start and enable it
sudo yum install mariadb105-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Automate mysql_secure_installation (not the best solution)
expect <<EOF
spawn mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\n"
expect "Set root password? [Y/n]"
send "Y\n"
expect "New password:"
send "root\n"  # Set your desired root password here
expect "Re-enter new password:"
send "root\n"  # Re-enter the root password
expect "Remove anonymous users? [Y/n]"
send "Y\n"
expect "Disallow root login remotely? [Y/n]"
send "Y\n"
expect "Remove test database and access to it? [Y/n]"
send "Y\n"
expect "Reload privilege tables now? [Y/n]"
send "Y\n"
expect eof
EOF

# Log in to mariadb and create WordPress database and user
mysql -u root -proot <<MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'admin123';  # Replace with actual password
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Install PHP and all necessary modules
sudo yum install php php-mysqlnd php-fpm php-xml php-mbstring -y
sudo systemctl restart httpd

# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz

# Move WordPress files to the Apache web directory
sudo mv wordpress/* /var/www/html/
sudo rm -f /var/www/html/index.html

# Set correct ownership and permissions
sudo chown -R apache:apache /var/www/html/*
sudo chmod -R 755 /var/www/html/*

# Create wp-config.php file
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php

# Automate wp-config.php with database credentials
sudo sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'wordpress' );/" wp-config.php
sudo sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'wp_user' );/" wp-config.php
sudo sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', 'admin123' );/" wp-config.php

# Set permissions for wp-config.php
sudo chmod 644 wp-config.php

# Restart Apache to ensure everything is loaded
sudo systemctl restart httpd

echo "WordPress installation is complete!" # just print a message