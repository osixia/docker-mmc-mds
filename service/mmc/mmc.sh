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

  # Create apache ssl certificate
  /sbin/create-ssl-cert mmc /etc/ssl/certs/mmc-ssl-cert.pem /etc/ssl/private/mmc-ssl-cert.key

  # a ldap container is linked to this phpLDAPadmin container
  if [ -n "${LDAP_NAME}" ]; then
    LDAP_HOST=${LDAP_PORT_389_TCP_ADDR}
    MMC_AGENT_LOGIN=${LDAP_ENV_MMC_AGENT_LOGIN}
    MMC_AGENT_PASSWORD=${LDAP_ENV_MMC_AGENT_PASSWORD}
  else
    LDAP_HOST=${LDAP_HOST}
    MMC_AGENT_LOGIN=${MMC_AGENT_LOGIN}
    MMC_AGENT_PASSWORD=${MMC_AGENT_PASSWORD}
  fi

  # MMC config
  sed -i -e "s?url = https://127.0.0.1:7080?url = https://$LDAP_HOST:7080?" /etc/mmc/mmc.ini
  sed -i -e "s/login = mmc/login = $MMC_AGENT_LOGIN/" /etc/mmc/mmc.ini
  sed -i -e "s/password = s3cr3t/password = $MMC_AGENT_PASSWORD/" /etc/mmc/mmc.ini

  touch /etc/mmc/docker_bootstrapped
fi

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
