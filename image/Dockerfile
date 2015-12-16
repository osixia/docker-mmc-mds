FROM osixia/web-baseimage:0.1.7
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
CMD ["/container/tool/run"]

# Install apache2 and php5-fpm using osixia/baseimage install-service-available util
# Caution: /container/tool/install-service-available arguments order is important
# php5-fpm install will detect apache2 and configure it

# Install mmc-web
RUN apt-get -y update \
		&& /container/tool/install-multiple-process-stack \
		&& /container/tool/install-service-available apache2 php5-fpm ssl-helper-openssl \
		&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
			 libapache2-mod-php5 \
			 php5-xmlrpc \
			 php5-gd \
			 wwwconfig-common

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script and clean all
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /container/environment/env.yaml

# Expose http and https default ports
EXPOSE 80 443
