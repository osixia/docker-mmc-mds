#!/bin/bash -e
# this script is run during the image build

dpkg -i --ignore-depends=libapache2-mod-php5,php5-gd,php5-xmlrpc /container/service/mmc-web/assets/package/mmc-web-base_3.9.90-10_all.deb
dpkg -i /container/service/mmc-web/assets/package/mmc-web-dashboard_3.9.90-10_all.deb
dpkg -i /container/service/mmc-web/assets/package/mmc-web-mail_2.5.1-1_all.deb
dpkg -i /container/service/mmc-web/assets/package/mmc-web-sshlpk_2.5.1-1_all.deb

rm -rf /container/service/mmc-agent/assets/package

cat /container/service/mmc-web/assets/php7.0-fpm/pool.conf >> /etc/php/7.0/fpm/pool.d/www.conf
rm /container/service/mmc-web/assets/php7.0-fpm/pool.conf

cp -f /container/service/mmc-web/assets/php7.0-fpm/opcache.ini /etc/php/7.0/fpm/conf.d/opcache.ini
rm /container/service/mmc-web/assets/php7.0-fpm/opcache.ini

# remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Add apache modules
a2enmod rewrite deflate expires

# change mmc-web default config
sed -i -e "s/#*\s*root\s*=.*/root = \//" /etc/mmc/mmc.ini
