#!/bin/bash -e

FIRST_START_DONE="/etc/docker-mmc-web-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create mmc-web vhost
  if [ "${MMC_WEB_HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-helper "/container/service/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_CRT_FILENAME" "/container/service/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_KEY_FILENAME" --ca-crt=/container/service/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_CA_CRT_FILENAME

    # add CA certificat config if CA cert exists
    if [ -e "/container/service/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_CA_CRT_FILENAME" ]; then
      sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" /container/service/mmc-web/assets/apache2/mmc-ssl.conf
    fi

    a2ensite mmc-ssl

  else
    a2ensite mmc
  fi

  # set mmc-agent login and password
  sed -i -e "s|#*\s*login\s*=.*|login = \"${MMC_WEB_MMC_AGENT_LOGIN}\"|" /etc/mmc/mmc.ini
  sed -i -e "s|#*\s*password\s*=.*|password = \"${MMC_WEB_MMC_AGENT_PASSWORD}\"|" /etc/mmc/mmc.ini

  # set mmc root url
  sed -i -e "s|#*\s*root\s*=.*|root = ${MMC_WEB_ROOT_URL}|" /etc/mmc/mmc.ini

  # disable community warning
  sed -i -e "s|#*\s*community\s*=.*|community = no|" /etc/mmc/mmc.ini

  # set maxperpage to 50
  sed -i -e "s|#*\s*maxperpage\s*=.*|maxperpage = 50|" /etc/mmc/mmc.ini

  # add global keys weakPassword and minsizepassword
  sed -i '/\[global\]/a weakPassword = 15'  /etc/mmc/mmc.ini
  sed -i '/\[global\]/a minsizepassword = 5'  /etc/mmc/mmc.ini

  # Config servers
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
      /sbin/ssl-helper "/container/service/mmc-agent-client/assets/certs/mmc-agent-client.tmp.crt" "/container/service/mmc-agent-client/assets/certs/mmc-agent-client.tmp.key" --ca-crt=/container/service/mmc-agent-client/assets/certs/mmc-agent-ca.crt

      # mmc agent need a pem file with the crt and the key
      cat /container/service/mmc-agent-client/assets/certs/mmc-agent-client.tmp.crt /container/service/mmc-agent-client/assets/certs/mmc-agent-client.tmp.key > /container/service/mmc-agent-client/assets/certs/mmc-agent-client.pem
      value="/container/service/mmc-agent-client/assets/certs/mmc-agent-client.pem"
    fi

    if [ "$key" = "cacert" ] && [ ! -e "$value" ]; then
      value="/container/service/mmc-agent-client/assets/certs/mmc-agent-ca.crt"
    fi

    echo "$key = $value" >> /etc/mmc/mmc.ini
  }

  SERVERS=($MMC_WEB_MMC_AGENT_HOSTS)
  i=1
  for server in "${SERVERS[@]}"
  do

    # section var contain a variable name, we access to the variable value and cast it to a table
    infos=(${!server})

    # it's a table of infos
    if [ "${#infos[@]}" -gt "1" ]; then

      echo "[server_$i]" >> /etc/mmc/mmc.ini
      echo "description = ${!infos[0]}" >> /etc/mmc/mmc.ini

      server_config "${infos[1]}"
    fi

    ((i++))
  done

  touch $FIRST_START_DONE
fi

# Fix file permission
chmod 400 /etc/mmc/mmc.ini
chown www-data:www-data /etc/mmc/mmc.ini
chown www-data:www-data -R /usr/share/mmc

exit 0
