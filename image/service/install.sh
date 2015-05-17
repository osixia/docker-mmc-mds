#!/bin/bash -e
# this script is run during the image build

# Add mmc-web virtualhosts
ln -s /osixia/mmc-web/apache2/mmc.conf /etc/apache2/sites-available/mmc.conf
ln -s /osixia/mmc-web/apache2/mmc-ssl.conf /etc/apache2/sites-available/mmc-ssl.conf

cat /osixia/mmc-web/php5-fpm/pool.conf >> /etc/php5/fpm/pool.d/www.conf
rm /osixia/mmc-web/php5-fpm/pool.conf

# Remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Enable apache rewrite module
a2enmod rewrite

# change mmc-web default config
sed -i -e "s/#*\s*root\s*=.*/root = \//" /etc/mmc/mmc.ini