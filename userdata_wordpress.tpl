#!/bin/bash

# Update and install Apache
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a simple test page
echo "<html><body><h1>Hello World</h1><p>Basic test page</p><p>RDS Endpoint: ${rds_endpoint}</p></body></html>" | sudo tee /var/www/html/index.html

# Create a health check file
echo "OK" | sudo tee /var/www/html/health.html

# Set permissions
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Restart Apache
sudo systemctl restart httpd

# Success message
echo "Basic web server setup complete. Access at: http://wordpress-alb-256857662.us-east-1.elb.amazonaws.com"
echo "Health check available at: http://wordpress-alb-256857662.us-east-1.elb.amazonaws.com/health.html"
