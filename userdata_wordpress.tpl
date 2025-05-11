#!/bin/bash

# Update system packages
sudo yum update -y

# Install Apache
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Install PHP and required extensions
sudo amazon-linux-extras enable php8.2
sudo yum clean metadata
sudo yum install -y php php-mysqlnd php-fpm php-xml php-mbstring php-cli php-json php-gd unzip git

# Download and extract WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo cp -r wordpress/* .
sudo rm -rf wordpress latest.tar.gz

# Configure wp-config.php with hardcoded credentials instead of undefined variables
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wordpressdb/" wp-config.php
sudo sed -i "s/username_here/admin/" wp-config.php
sudo sed -i "s/password_here/Admin123!/" wp-config.php
sudo sed -i "s/localhost/${rds_endpoint}/" wp-config.php

# FIXING CONNECTION BUG
# Debug database connection
sudo echo "==== DATABASE CONNECTION DEBUGGING ====" >> /var/log/wordpress_debug.log
sudo echo "RDS Endpoint: ${rds_endpoint}" >> /var/log/wordpress_debug.log
sudo echo "Testing connection to database..." >> /var/log/wordpress_debug.log
sudo yum install -y nc
sudo echo "Checking if port 3306 is reachable..." >> /var/log/wordpress_debug.log
sudo nc -zv ${rds_endpoint} 3306 >> /var/log/wordpress_debug.log 2>&1
sudo echo "Trying to connect to MySQL..." >> /var/log/wordpress_debug.log
sudo mysql -h ${rds_endpoint} -u admin -p'Admin123!' -e "SHOW DATABASES;" >> /var/log/wordpress_debug.log 2>&1
sudo echo "==== END DATABASE DEBUGGING ====" >> /var/log/wordpress_debug.log

# Generate unique keys and salts (important for security)
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
SALT=$(echo "$SALT" | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
sudo sed -i "/define( 'AUTH_KEY'/,/define( 'NONCE_SALT'/d" wp-config.php
sudo sed -i "/Put your unique phrase here/a $SALT" wp-config.php

# Set permissions
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Create themes directory if it doesn't exist
sudo mkdir -p /var/www/html/wp-content/themes/twentytwentyfive

# Install WP-CLI
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Install WordPress with the load balancer URL
cd /var/www/html
sudo wp core install \
  --url="http://wordpress-alb-256857662.us-east-1.elb.amazonaws.com" \
  --title="Capstone Project" \
  --admin_user=admin \
  --admin_password=Test123# \
  --admin_email="admin@example.com" \
  --skip-email \
  --allow-root

# Also update the WordPress URL settings
sudo wp option update home 'http://wordpress-alb-256857662.us-east-1.elb.amazonaws.com' --allow-root
sudo wp option update siteurl 'http://wordpress-alb-256857662.us-east-1.elb.amazonaws.com' --allow-root

# Activate default theme
sudo wp theme activate twentytwentyfive --allow-root

# Restart Apache
sudo systemctl restart httpd

# Success message
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "WORDPRESS SUCCESSFULLY INSTALLED! Access at: http://wordpress-alb-256857662.us-east-1.elb.amazonaws.com"
echo "If you see the test page:"
echo "1. Clear browser cache (Ctrl+F5)"
echo "2. Make sure port 80 is open in the security group"
