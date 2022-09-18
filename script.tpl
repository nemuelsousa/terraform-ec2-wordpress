#!/bin/bash

sleep 5m

sudo su -

yum -y update all
amazon-linux-extras enable php8.0
yum install -y amazon-efs-utils

efs_id="${efs_id}"
echo "$efs_id:/ /var/www/html efs defaults,_netdev 0 0" >> /etc/fstab

yum -y install httpd php php-gd php-mysqlnd php-json php-devel

mount -a

if [ ! -e /var/www/html/wp-admin ]; then   
  cd /tmp
  wget https://wordpress.org/latest.tar.gz
  tar -xzf /tmp/latest.tar.gz --strip 1 -C /var/www/html
  rm -rf /tmp/latest.tar.gz
fi

chown -R apache:apache /var/www/html

systemctl enable httpd
systemctl start httpd