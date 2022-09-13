#!/bin/bash

sleep 5m

sudo su -
yum install -y amazon-efs-utils

efs_id="${efs_id}"
echo "$efs_id:/ /var/www/html efs defaults,_netdev 0 0" >> /etc/fstab

mkdir -p /var/www/html

mount -a