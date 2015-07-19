FROM osixia/light-baseimage:0.1.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage-docker's init system.
CMD ["/osixia/tool/run"]

# Install apache2 and php5-fpm using osixia/baseimage utils
# Caution: /sbin/install-service-available arguments order is important
# php5-fpm install will detect apache2 and configure it

# Install mmc-web
RUN apt-get -y update && /sbin/install-multiple-process-stack \
	&& /sbin/install-service-available apache2 php5-fpm ssl-helper-openssl \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
	libapache2-mod-php5 \
	php5-xmlrpc \
	php5-gd \
	wwwconfig-common

# Add service directory to /osixia/service
ADD service /osixia/service

# Use baseimage install-service script and clean all
RUN ./sbin/install-service && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /etc/env.yaml

# Expose http and https default ports
EXPOSE 80 443
