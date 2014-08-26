#!/bin/bash

# -e Exit immediately if a command exits with a non-zero status
if [ ! -e /etc/mmc/docker_bootstrapped ]; then

  ## Apache config
  # Add ssl module
  a2enmod ssl

  # Add rewrite module
  a2enmod rewrite

  #disable default site
  a2dissite 000-default

  # Enable mmc site
  a2ensite mmc

  # Create ssl certificate
  /sbin/create-ssl-cert mmc /etc/ssl/certs/mmc-ssl-cert.pem /etc/ssl/private/mmc-ssl-cert.key

  touch /etc/mmc/agent/docker_bootstrapped
fi

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
