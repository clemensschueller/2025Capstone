#!/bin/bash
set -x  # Debug-Modus

# 1. Apache-Testseite LÖSCHEN (kritisch!)
sudo rm -f /var/www/html/index.html

# 2. Pakete installieren
sudo yum update -y
sudo amazon-linux-extras enable -y php8.2 mariadb10.5
sudo yum install -y httpd mariadb-server php php-{mysqlnd,gd,mbstring,xml}

# 3. WordPress herunterladen
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo mv wordpress/* /var/www/html/

# 4. Dateiberechtigungen setzen
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# 5. Datenbank einrichten (Sandbox-Modus)
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
sudo sed -i "s/database_name_here/wordpress/; s/username_here/wp_user/; s/password_here/admin123/" wp-config.php

# 7. Apache KONFIGURIEREN (wichtig!)
sudo tee /etc/httpd/conf.d/wordpress.conf > /dev/null <<EOF
<Directory "/var/www/html">
    AllowOverride All
    DirectoryIndex index.php
    Require all granted
</Directory>
EOF

# 8. Apache NEUSTARTEN (absolut kritisch)
sudo systemctl restart httpd

# Erfolgsmeldung
echo "WORDPRESS LÄUFT! Zugriff unter: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"