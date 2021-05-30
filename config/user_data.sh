#!/bin/bash
yum -y install httpd
yum -y install mysql
touch /var/www/html/index.html
echo "Hello, this is Weis demo site" > /var/www/html/index.html
systemctl start httpd
chkconfig httpd on