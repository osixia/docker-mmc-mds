#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

status () {
  echo "---> ${@}" >&2
}

getBaseDn () {
  IFS="."
  export IFS

  domain=$1
  init=1

  for s in $domain; do
    dc="dc=$s"
    if [ "$init" -eq 1 ]; then
      baseDn=$dc
      init=0
    else
      baseDn="$baseDn,$dc" 
    fi
  done
}

# a ldap container is linked to this phpLDAPadmin container
if [ -n "${LDAP_NAME}" ]; then
  LDAP_HOST=${LDAP_PORT_389_TCP_ADDR}
  
  # Get base dn from ldap domain
  getBaseDn ${LDAP_ENV_LDAP_DOMAIN}

  LDAP_BASE_DN=$baseDn
  LDAP_LOGIN_DN="cn=admin,$baseDn"
else
  LDAP_HOST=${LDAP_HOST}
  LDAP_BASE_DN=${LDAP_BASE_DN}
  LDAP_LOGIN_DN=${LDAP_LOGIN_DN}
fi

if [ ! -e /etc/mmc/docker_bootstrapped ]; then
  status "configuring mmc-agent for first run"

  sed -i -e "s/127.0.0.1/$LDAP_HOST/" /etc/mmc/plugins/base.ini
  sed -i -e "s/dc=mandriva, dc=com/$LDAP_BASE_DN/" /etc/mmc/plugins/base.ini
  sed -i -e "s/password = secret/password = $LDAP_ADMIN_PWD/" /etc/mmc/plugins/base.ini

  mkdir /home/archives

  # Mail plugin

  sed -i -e 's/vDomainSupport = 0/vDomainSupport = 1/g' /etc/mmc/plugins/mail.ini
  sed -i -e 's/vAliasesSupport = 0/vAliasesSupport = 1/g' /etc/mmc/plugins/mail.ini
  cat /etc/ldap/config/append_to_mail.ini >> /etc/mmc/plugins/mail.ini

  touch /etc/mmc/docker_bootstrapped
else
  status "found already-configured mmc-agent"
fi

exec /usr/sbin/mmc-agent -d
