#!/bin/bash -e

FIRST_START_DONE="/etc/docker-mmc-web-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create mmc-web vhost
  if [ "${HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-helper "/osixia/service/mmc-web/assets/apache2/ssl/$SSL_CRT_FILENAME" "/osixia/service/mmc-web/assets/apache2/ssl/$SSL_KEY_FILENAME" --ca-crt=/osixia/service/mmc-web/assets/apache2/ssl/$SSL_CA_CRT_FILENAME

    # add CA certificat config if CA cert exists
    if [ -e "/osixia/service/mmc-web/assets/apache2/ssl/$SSL_CA_CRT_FILENAME" ]; then
      sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" /osixia/service/mmc-web/assets/apache2/mmc-ssl.conf
    fi

    a2ensite mmc-ssl

  else
    a2ensite mmc
  fi

  # set mmc-agent login and password
  sed -i -e "s/#*\s*login\s*=.*/login = $MMC_AGENT_LOGIN/" /etc/mmc/mmc.ini
  sed -i -e "s/#*\s*password\s*=.*/password = $MMC_AGENT_PASSWORD/" /etc/mmc/mmc.ini


  # config servers
  # delete default server config
  sed -i '/.*\[server_01\].*/,$d' /etc/mmc/mmc.ini


  server_config() {

    local infos=(${!1})

    for info in "${infos[@]}"
    do
      server_config_value "$info"
    done
  }

  server_config_value() {

    local info_key_value=(${!1})

    local key=${!info_key_value[0]}
    local value=${!info_key_value[1]}

    if [ "$key" = "localcert" ] && [ ! -e "$value" ]; then
      /sbin/ssl-helper "/osixia/service/mmc-web/assets/ssl/mmc-agent-client.tmp.crt" "/osixia/service/mmc-web/assets/ssl/mmc-agent-client.tmp.key" --ca-crt=/osixia/service/mmc-web/assets/ssl/mmc-agent-ca.crt

      # mmc agent need a pem file with the crt and the key
      cat /osixia/service/mmc-web/assets/ssl/mmc-agent-client.tmp.crt /osixia/service/mmc-web/assets/ssl/mmc-agent-client.tmp.key > /osixia/service/mmc-web/assets/ssl/mmc-agent-client.pem
      value="/osixia/service/mmc-web/assets/ssl/mmc-agent-client.pem"
    fi

    if [ "$key" = "cacert" ] && [ ! -e "$value" ]; then
      value="/osixia/service/mmc-web/assets/ssl/mmc-agent-ca.crt"
    fi

    echo "$key = $value" >> /etc/mmc/mmc.ini
  }

  SERVERS=($MMC_AGENT_SERVERS)
  i=1
  for server in "${SERVERS[@]}"
  do

    #section var contain a variable name, we access to the variable value and cast it to a table
    infos=(${!server})

    # it's a table of infos
    if [ "${#infos[@]}" -gt "1" ]; then

      echo "[server_$i]" >> /etc/mmc/mmc.ini
      echo "description = ${!infos[0]}" >> /etc/mmc/mmc.ini

      server_config "${infos[1]}"
    fi

    ((i++))
  done


  # Fix file permission
  chmod 400 /etc/mmc/mmc.ini
  chown www-data:www-data /etc/mmc/mmc.ini
  chown www-data:www-data -R /usr/share/mmc

  touch $FIRST_START_DONE
fi

exit 0
