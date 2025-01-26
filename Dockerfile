ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}

RUN curl -sSLf \
  -o /usr/local/bin/install-php-extensions \
  https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
  chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions @composer

ENV PATH="$PATH:~/.composer/vendor/bin"

RUN echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

WORKDIR /app
