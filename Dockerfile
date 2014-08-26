FROM osixia/baseimage:0.8.2
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# From Nick Stenning's work
# https://github.com/nickstenning/docker-slapd

# Default configuration: can be overridden at the docker command line
ENV LDAP_HOST example.com
ENV LDAP_BASE_DN dc=example,dc=com
ENV LDAP_ADMIN_DN cn=admin,dc=example,dc=com
ENV LDAP_ADMIN_PWD toor

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

# Expose http and https default ports
EXPOSE 80 443

# Add config directory 
#RUN mkdir /etc/ldap/config
#ADD service/mmc-agent/assets /etc/ldap/config

# Add mmc deamon
RUN mkdir /etc/service/mmc
ADD service/mmc/mmc.sh /etc/service/mmc/run

# Copy mmc apache config
ADD service/mmc/assets/apache2.conf /etc/apache2/sites-available/mmc.conf

# Add mmc-agent deamon
RUN mkdir /etc/service/mmc-agent
ADD service/mmc-agent/mmc-agent.sh /etc/service/mmc-agent/run

# Copy mmc-agent config
ADD service/mmc-agent/assets /etc/mmc/agent

# Clear out the local repository of retrieved package files
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
