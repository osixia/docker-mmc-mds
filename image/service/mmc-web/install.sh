#!/bin/bash -e
# this script is run during the image build

dpkg -i /osixia/service/mmc-web/assets/package/mmc-web-base_3.1.1-3_all.deb
dpkg -i /osixia/service/mmc-web/assets/package/mmc-web-dashboard_3.1.1-3_all.deb
dpkg -i /osixia/service/mmc-web/assets/package/mmc-web-mail_2.5.1-1_all.deb
dpkg -i /osixia/service/mmc-web/assets/package/mmc-web-ppolicy_3.1.1-3_all.deb
dpkg -i /osixia/service/mmc-web/assets/package/mmc-web-sshlpk_2.5.1-1_all.deb

rm -rf /osixia/service/mmc-agent/assets/package

# Add mmc-web virtualhosts
ln -s /osixia/service/mmc-web/assets/apache2/mmc.conf /etc/apache2/sites-available/mmc.conf
ln -s /osixia/service/mmc-web/assets/apache2/mmc-ssl.conf /etc/apache2/sites-available/mmc-ssl.conf

cat /osixia/service/mmc-web/assets/php5-fpm/pool.conf >> /etc/php5/fpm/pool.d/www.conf
rm /osixia/service/mmc-web/assets/php5-fpm/pool.conf

# Remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Enable apache rewrite module
a2enmod rewrite

# change mmc-web default config
sed -i -e "s/#*\s*root\s*=.*/root = \//" /etc/mmc/mmc.ini
