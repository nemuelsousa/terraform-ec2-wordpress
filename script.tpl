#!/bin/bash

sleep 5m

sudo su -

yum update -y
yum install -y amazon-efs-utils

efs_id="${efs_id}"
echo "$efs_id:/ /var/www/html efs defaults,_netdev 0 0" >> /etc/fstab

yum install wget php-mysqlnd httpd php-fpm php-mysqli php-json php php-gd php72-gd php-devel -y

mount -a

if [ ! -e /var/www/html/wp-admin ]; then   
  cd /tmp
  wget https://wordpress.org/wordpress-5.0.7.tar.gz
  tar xzvf /tmp/wordpress-5.0.7.tar.gz --strip 1 -C /var/www/html
  rm /tmp/wordpress-5.0.7.tar.gz
fi

chown -R apache:apache /var/www/html

systemctl enable httpd
systemctl start httpd