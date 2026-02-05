FROM php:8.2-apache
MAINTAINER Kristoph Junge <kristoph.junge@gmail.com>

# Utilities
RUN apt-get update && \
    apt-get -y install apt-transport-https git curl vim --no-install-recommends && \
    rm -r /var/lib/apt/lists/*

# SimpleSAMLphp
ARG SIMPLESAMLPHP_VERSION=2.4.4
RUN curl -s -L -o /tmp/simplesamlphp.tar.gz https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SIMPLESAMLPHP_VERSION/simplesamlphp-$SIMPLESAMLPHP_VERSION-full.tar.gz && \
    tar xzf /tmp/simplesamlphp.tar.gz -C /tmp && \
    rm -f /tmp/simplesamlphp.tar.gz  && \
    mv /tmp/simplesamlphp-* /var/simplesamlphp && \
    touch /var/simplesamlphp/modules/exampleauth/enable
COPY config/simplesamlphp/config.php /var/simplesamlphp/config
COPY config/simplesamlphp/authsources.php /var/simplesamlphp/config
COPY config/simplesamlphp/saml20-sp-remote.php /var/simplesamlphp/metadata
COPY config/simplesamlphp/saml20-idp-hosted.php /var/simplesamlphp/metadata
COPY config/simplesamlphp/server.crt /var/simplesamlphp/cert/
COPY config/simplesamlphp/server.pem /var/simplesamlphp/cert/

# Apache
COPY config/apache/ports.conf /etc/apache2
COPY config/apache/simplesamlphp.conf /etc/apache2/sites-available
COPY config/apache/cert.crt /etc/ssl/cert/cert.crt
COPY config/apache/private.key /etc/ssl/private/private.key
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod ssl && \
    a2dissite 000-default.conf default-ssl.conf && \
    a2ensite simplesamlphp.conf

# Set work dir
WORKDIR /var/www/simplesamlphp

RUN chmod 777 /var/simplesamlphp

# General setup
EXPOSE 8080 8443
