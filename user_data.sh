#!/bin/bash
# WordPress-Sandbox-Installation (Amazon Linux 2) - Sofort einsatzbereit
set -x  # Debug-Ausgabe aktivieren

# 1. Systemaktualisierung und Apache-Installation
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php8.2 php8.2
sudo yum install -y httpd mariadb-server

# 2. Dienste starten
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl enable mariadb

# 3. MariaDB-Setup (extrem vereinfacht für Sandbox)
sudo mysql <<EOF
CREATE DATABASE wordpress;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# 4. WordPress herunterladen und entpacken
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz --strip-components=1
sudo rm latest.tar.gz

# 5. wp-config.php anpassen (Sandbox-Shortcut)
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wordpress/
             s/username_here/wp_user/
             s/password_here/admin123/" wp-config.php

# 6. Dateiberechtigungen (Sandbox-optimiert)
sudo chown -R apache:apache /var/www/html
sudo chmod -R 775 /var/www/html

# 7. Apache für WordPress konfigurieren
echo "<Directory '/var/www/html'>
    AllowOverride All
</Directory>" | sudo tee /etc/httpd/conf.d/wordpress.conf

# 8. Finaler Restart
sudo systemctl restart httpd

# 9. Öffentliche IP anzeigen (für direkten Zugriff)
echo "WORDPRESS BEREIT! Zugriff unter: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"