#!/bin/bash
set -x  # Debug-Modus aktivieren

# 1. Apache-Testseite DEAKTIVIEREN (kritisch!)
sudo sed -i 's/^/#/' /etc/httpd/conf.d/welcome.conf  # Kommentiert die Testseite aus

# 2. Alte Inhalte löschen
sudo rm -rf /var/www/html/*

# 3. System aktualisieren
sudo yum update -y
sudo amazon-linux-extras enable -y php8.2 mariadb10.5
sudo yum install -y httpd mariadb-server php php-{mysqlnd,gd,mbstring,xml,json,curl}

# 4. Dienste starten
sudo systemctl start httpd mariadb
sudo systemctl enable httpd mariadb

# 5. WordPress herunterladen
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo mv wordpress/* /var/www/html/

# 6. Berechtigungen setzen
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# 7. Datenbank einrichten
sudo mysql <<EOF
CREATE DATABASE wordpress;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# 8. wp-config anpassen
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "
  s/database_name_here/wordpress/;
  s/username_here/wp_user/;
  s/password_here/admin123/
" wp-config.php

# 9. Apache KORREKT konfigurieren
sudo tee /etc/httpd/conf.d/wordpress.conf > /dev/null <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html
    <Directory "/var/www/html">
        AllowOverride All
        DirectoryIndex index.php
        Require all granted
    </Directory>
</VirtualHost>
EOF

# 10. Apache NEUSTARTEN (absolut kritisch)
sudo systemctl restart httpd

# Erfolgsmeldung
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "WORDPRESS ERFOLGREICH INSTALLIERT! Zugriff unter: http://$IP"
echo "Falls du die Testseite siehst:"
echo "1. Browser-Cache leeren (Strg+F5)"
echo "2. Sicherstellen, dass Port 80 in der Security Group offen ist"