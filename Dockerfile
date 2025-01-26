ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions @composer

ENV PATH="$PATH:~/.composer/vendor/bin"

RUN echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

WORKDIR /app
