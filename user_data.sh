#!/bin/bash

# Update system packages
yum update -y

# Install Apache
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Install PHP and required extensions
amazon-linux-extras enable php8.2
yum clean metadata
# Added php-json and php-gd which WordPress needs
yum install -y php php-mysqlnd php-fpm php-xml php-mbstring php-cli php-json php-gd unzip git

# Download and extract WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Configure wp-config.php with hardcoded credentials instead of undefined variables
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpressdb/" wp-config.php
sed -i "s/username_here/admin/" wp-config.php
sed -i "s/password_here/Password123!/" wp-config.php
sed -i "s/localhost/rds-db.cxxxxxxxxxxx.us-east-1.rds.amazonaws.com/" wp-config.php

# Generate unique keys and salts (important for security)
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
SALT=$(echo "$SALT" | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
sed -i "/define( 'AUTH_KEY'/,/define( 'NONCE_SALT'/d" wp-config.php
sed -i "/Put your unique phrase here/a $SALT" wp-config.php

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Create themes directory if it doesn't exist
mkdir -p /var/www/html/wp-content/themes/twentytwentyfive

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Install WordPress with the actual server IP instead of localhost
cd /var/www/html
wp core install \
  --url="http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" \
  --title="Capstone Project" \
  --admin_user=admin \
  --admin_password=Test123# \
  --admin_email="admin@example.com" \
  --skip-email \
  --allow-root

# Activate default theme
wp theme activate twentytwentyfive --allow-root

# Restart Apache
systemctl restart httpd

# Success message
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "WORDPRESS SUCCESSFULLY INSTALLED! Access at: http://$IP"
echo "If you see the test page:"
echo "1. Clear browser cache (Ctrl+F5)"
echo "2. Make sure port 80 is open in the security group"
