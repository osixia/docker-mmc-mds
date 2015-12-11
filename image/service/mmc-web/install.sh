#!/bin/bash -e
# this script is run during the image build

dpkg -i /container/service/mmc-web/assets/package/mmc-web-base_3.1.1-3_all.deb
dpkg -i /container/service/mmc-web/assets/package/mmc-web-dashboard_3.1.1-3_all.deb
dpkg -i /container/service/mmc-web/assets/package/mmc-web-mail_2.5.1-1_all.deb
dpkg -i /container/service/mmc-web/assets/package/mmc-web-sshlpk_2.5.1-1_all.deb

rm -rf /container/service/mmc-agent/assets/package

# add mmc-web virtualhosts
ln -s /container/service/mmc-web/assets/apache2/mmc.conf /etc/apache2/sites-available/mmc.conf
ln -s /container/service/mmc-web/assets/apache2/mmc-ssl.conf /etc/apache2/sites-available/mmc-ssl.conf

cat /container/service/mmc-web/assets/php5-fpm/pool.conf >> /etc/php5/fpm/pool.d/www.conf
rm /container/service/mmc-web/assets/php5-fpm/pool.conf

# remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# enable apache rewrite module
a2enmod rewrite

# change mmc-web default config
sed -i -e "s/#*\s*root\s*=.*/root = \//" /etc/mmc/mmc.ini
