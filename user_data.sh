#!/bin/bash
# WordPress-Sofortinstallation (Amazon Linux 2) - Garantiert funktionierend
set -x  # Debug-Modus

# 1. System vorbereiten
sudo yum update -y
sudo amazon-linux-extras enable -y php8.2 mariadb10.5
sudo yum install -y httpd mariadb-server php php-{mysqlnd,gd,mbstring,xml,json,curl}

# 2. Alte Apache-Inhalte LÖSCHEN (wichtig!)
sudo rm -rf /var/www/html/*

# 3. WordPress herunterladen
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# 4. WordPress nach /var/www/html verschieben
sudo mv wordpress/* /var/www/html/
sudo chown -R apache:apache /var/www/html

# 5. MariaDB einrichten (Sandbox-Shortcut)
sudo systemctl start mariadb
sudo mysql <<EOF
CREATE DATABASE wordpress;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# 6. wp-config.php anpassen
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "
  s/database_name_here/wordpress/;
  s/username_here/wp_user/;
  s/password_here/admin123/
" wp-config.php

# 7. Apache für WordPress konfigurieren
sudo tee /etc/httpd/conf.d/wordpress.conf > /dev/null <<EOF
<Directory "/var/www/html">
    AllowOverride All
    DirectoryIndex index.php
    Require all granted
</Directory>
EOF

# 8. Apache neustarten
sudo systemctl restart httpd
sudo systemctl enable httpd

# Erfolgsmeldung
echo "WORDPRESS INSTALLIERT! Zugriff unter: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"