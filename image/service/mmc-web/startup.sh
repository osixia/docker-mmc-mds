#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x


#
# HTTPS config
#
if [ "${MMC_WEB_HTTPS,,}" == "true" ]; then

  log-helper info "Set apache2 https config..."

  # generate a certificate and key if files don't exists
  # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:cfssl/assets/tool/cfssl-helper
  cfssl-helper ${MMC_WEB_CFSSL_PREFIX} "${CONTAINER_SERVICE_DIR}/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_CA_CRT_FILENAME"

  # add CA certificat config if CA cert exists
  if [ -e "${CONTAINER_SERVICE_DIR}/mmc-web/assets/apache2/certs/$MMC_WEB_HTTPS_CA_CRT_FILENAME" ]; then
    sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" ${CONTAINER_SERVICE_DIR}/mmc-web/assets/apache2/https.conf
  fi

  ln -sf ${CONTAINER_SERVICE_DIR}/mmc-web/assets/apache2/https.conf /etc/apache2/sites-available/mmc-web.conf
#
# HTTP config
#
else
  log-helper info "Set apache2 http config..."
  ln -sf ${CONTAINER_SERVICE_DIR}/mmc-web/assets/apache2/http.conf /etc/apache2/sites-available/mmc-web.conf
fi

a2ensite mmc-web | log-helper debug


FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-mmc-web-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # set mmc-agent login and password
  sed -i --follow-symlinks -e "s|#*\s*login\s*=.*|login = \"${MMC_WEB_MMC_AGENT_LOGIN}\"|" /etc/mmc/mmc.ini
  sed -i --follow-symlinks -e "s|#*\s*password\s*=.*|password = \"${MMC_WEB_MMC_AGENT_PASSWORD}\"|" /etc/mmc/mmc.ini

  # set mmc root url
  sed -i --follow-symlinks -e "s|#*\s*root\s*=.*|root = ${MMC_WEB_ROOT_URL}|" /etc/mmc/mmc.ini

  # disable community warning
  sed -i --follow-symlinks -e "s|#*\s*community\s*=.*|community = no|" /etc/mmc/mmc.ini

  # set maxperpage to 50
  sed -i --follow-symlinks -e "s|#*\s*maxperpage\s*=.*|maxperpage = 50|" /etc/mmc/mmc.ini

  # add global keys weakPassword and minsizepassword
  sed -i --follow-symlinks '/\[global\]/a weakPassword = 15'  /etc/mmc/mmc.ini
  sed -i --follow-symlinks '/\[global\]/a minsizepassword = 5'  /etc/mmc/mmc.ini

  # Config servers
  # delete default server config
  sed -i --follow-symlinks '/.*\[server_01\].*/,$d' /etc/mmc/mmc.ini

  # mmc-web agent host config
  host_info(){

    for info in $(complex-bash-env iterate "$1")
    do
      if [ $(complex-bash-env isRow "${!info}") = true ]; then
        local key=$(complex-bash-env getRowKey "${!info}")
        local value=$(complex-bash-env getRowValue "${!info}")

        if [ "$key" = "localcert" ] && [ ! -e "$value" ]; then
          # generate a certificate and key if files don't exists
          # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:cfssl/assets/tool/cfssl-helper
          cfssl-helper ${MMC_AGENT_CFSSL_PREFIX} "${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-client.tmp.crt" "${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-client.tmp.key" "${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-ca.crt"

          # mmc agent need a pem file with the crt and the key
          cat ${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-client.tmp.crt ${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-client.tmp.key > ${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-client.pem
          value="${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-client.pem"
        fi

        if [ "$key" = "cacert" ] && [ ! -e "$value" ]; then
          value="${CONTAINER_SERVICE_DIR}/mmc-agent-client/assets/certs/mmc-agent-ca.crt"
        fi

        echo "$key = $value" >> /etc/mmc/mmc.ini
      fi
    done
  }

  # mmc-web agent config
  i=1
  for host in $(complex-bash-env iterate MMC_WEB_MMC_AGENT_HOSTS)
  do
    # section var contain a variable name, we access to the variable value and cast it to a table
    infos=(${!server})

    if [ $(complex-bash-env isRow "${!host}") = true ]; then

      hostname=$(complex-bash-env getRowKey "${!host}")
      info=$(complex-bash-env getRowValueVarName "${!host}")

      echo "[server_$i]" >> /etc/mmc/mmc.ini
      echo "description = $hostname" >> /etc/mmc/mmc.ini

      host_info "$info"
    else
      exit 1
    fi

    ((i++))
  done

  cp -f /etc/mmc/mmc.ini ${CONTAINER_SERVICE_DIR}/mmc-web/assets/mmc.ini

  touch $FIRST_START_DONE
fi

ln -sf ${CONTAINER_SERVICE_DIR}/mmc-web/assets/mmc.ini /etc/mmc/mmc.ini

# Fix file permission
chmod 400 /etc/mmc/mmc.ini
chown www-data:www-data /etc/mmc/mmc.ini
chown www-data:www-data -R /usr/share/mmc

exit 0
