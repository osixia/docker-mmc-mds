FROM osixia/baseimage:0.8.2
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.fr>

# From Nick Stenning's work
# https://github.com/nickstenning/docker-slapd

# Default configuration: can be overridden at the docker command line
ENV LDAP_ADMIN_PWD toor
ENV LDAP_ORGANISATION Example Inc.
ENV LDAP_DOMAIN example.com

# Disable SSH
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add Mandriva MDS repository
RUN echo "deb http://mds.mandriva.org/pub/mds/debian wheezy main" >> /etc/apt/sources.list

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install openldap (slapd),ldap-utils and mmc tools
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends mmc-agent python-mmc-base python-mmc-mail mmc-web-base mmc-web-mail 

# Expose ldap and mmc-agent default ports
EXPOSE 80 443


# Add config directory 
#RUN mkdir /etc/ldap/config
#ADD service/mmc-agent/assets /etc/ldap/config

# mmc-agent config on container start
#RUN mkdir -p /etc/my_init.d
#ADD service/mmc-agent/install.sh /etc/my_init.d/mmc-agent.sh

# Add mmc-agent deamon
#RUN mkdir /etc/service/mmc-agent
#ADD service/mmc-agent/mmc-agent.sh /etc/service/mmc-agent/run

# Add slapd deamon
#RUN mkdir /etc/service/slapd
#ADD service/slapd/slapd.sh /etc/service/slapd/run

# Clear out the local repository of retrieved package files
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
