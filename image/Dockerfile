FROM osixia/web-baseimage:1.1.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Install apache2 and php7.0-fpm using osixia/baseimage install-service-available util
# Caution: /container/tool/install-service-available arguments order is important
# php7.0-fpm install will detect apache2 and configure it

# Add multiple process stack to supervise apache2, php7.0-fpm and ssl-tools
# sources: https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-multiple-process-stack
#          https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-service-available
#          https://github.com/osixia/docker-web-baseimage/blob/stable/image/service-available/:apache2/download.sh
#          https://github.com/osixia/docker-web-baseimage/blob/stable/image/service-available/:php7.0-fpm/download.sh
#          https://github.com/osixia/light-baseimage/blob/stable/image/service-available/:ssl-tools/download.sh
RUN apt-get -y update \
		&& /container/tool/add-multiple-process-stack \
		&& /container/tool/add-service-available :apache2 :php7.0-fpm :ssl-tools \
		&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
			 php7.0-gd \
			 php7.0-xmlrpc \
			 wwwconfig-common \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD environment /container/environment/99-default

# Expose http and https default ports
EXPOSE 80 443
