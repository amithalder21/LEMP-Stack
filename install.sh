#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
yum update -y
yum install wget epel-release curl nano -y

## Installing Mariadb

if [ ! -x /usr/bin/mysql ];
   then
      echo "MARIADB will be INSTALLED now"
      yum -y install mariadb mariadb-server
      systemctl start mariadb
      systemctl enable mariadb
   else
      echo #############################################################################
      echo "MARIADB is already INSTALLED"
      echo #############################################################################
      exit 1
fi
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
echo Mysql root password = $password > /root/LEMPpassword.txt
mysql_secure_installation <<EOF

y
$password
$password
y
n
y
y
EOF

# Installing Nginx

if [ ! -x /usr/sbin/nginx ];
    then
        echo "NGINX will be INSTALLED now"
        yum install nginx -y
        systemctl start nginx
        systemctl enable nginx
    else
        echo #############################################################################
        echo "NGINX is already INSTALLED"
        echo #############################################################################
fi


## Installing PHP

if [ ! -x /usr/bin/php ];
   then
      echo "PHP will be INSTALLED now"
      yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
      yum --disablerepo="*" --enablerepo="remi-safe" list php[7-9][0-9].x86_64 |grep php
      echo #############################################################################
      read -p "Select one PHP version from above...like php70,php71,php80  " phpv
      echo #############################################################################
      yum-config-manager --enable remi-$phpv
      yum install php php-common php-mbstring php-gd php-intl php-xml php-json php-mysqlnd php-fpm -y
   else
      echo #############################################################################
      echo "PHP is already installed"
      echo #############################################################################
fi

#Changing PHP-FPM according to Nginx

sed -i's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
systemctl restart php-fpm


