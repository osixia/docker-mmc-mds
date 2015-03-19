FROM osixia/baseimage:0.10.4
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add MDS repository
RUN echo "deb http://mds.mandriva.org/pub/mds/debian wheezy main" > /etc/apt/sources.list.d/mds.list

# Install apache2 and php5-fpm using osixia/baseimage utils
# Caution: /sbin/enable-service arguments order is important
# php5-fpm install will detect apache2 and configure it

# Install mmc-web
RUN apt-get -y update && /sbin/enable-service apache2 php5-fpm ssl-kit \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
	mmc-web-base \
	mmc-web-dashboard \
	mmc-web-ppolicy \
	mmc-web-mail

# Add install script and mmc-web assets
ADD service/install.sh /tmp/install.sh
ADD service/mmc-web/assets /osixia/mmc-web

# Run install script and clean all
RUN ./tmp/install.sh \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yml /etc/env.yml

# Add mmc-web container start config
ADD service/mmc-web/container-start.sh /etc/my_init.d/mmc-web

# Expose http and https default ports
EXPOSE 80 443