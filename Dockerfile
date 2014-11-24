FROM osixia/baseimage:0.10.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# From Nick Stenning's work
# https://github.com/nickstenning/docker-slapd

# Default configuration: can be overridden at the docker command line
ENV LDAP_HOST example.com
ENV MMC_AGENT_LOGIN mmc-docker
ENV MMC_AGENT_PASSWORD passw0rd

# Disable SSH
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Enable dnsmasq
RUN /sbin/enable-service ca-authority

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add Mandriva MDS repository
RUN echo "deb http://mds.mandriva.org/pub/mds/debian wheezy main" >> /etc/apt/sources.list

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install openldap (slapd),ldap-utils and mmc tools
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends mmc-web-base mmc-web-mail

# Expose http and https default ports
EXPOSE 80 443

# Add mmc deamon
RUN mkdir /etc/service/mmc
ADD service/mmc/mmc.sh /etc/service/mmc/run

# Copy mmc apache config
ADD service/mmc/assets/apache2.conf /etc/apache2/sites-available/mmc.conf

# Clear out the local repository of retrieved package files
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
