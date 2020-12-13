ARG PHP_VERSION=7.2
FROM php:${PHP_VERSION}-apache

COPY scripts/ /scripts

# Configure php extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
        libjpeg-dev \
        libpng-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libzip-dev \
        git \
        zip \
        libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install zip
RUN docker-php-ext-install exif
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-install soap
RUN pecl install imagick && docker-php-ext-enable imagick

RUN /scripts/install-gd.sh

# Composer & Craft CLI
RUN curl --silent --show-error https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer

ENV PATH "$PATH:~/.composer/vendor/bin"

# Apache Extensions
RUN a2enmod headers rewrite expires deflate

# Volumes
RUN usermod --non-unique --uid 1000 www-data
RUN chown -R 1000:1000 /var/www/html
VOLUME /var/www/html
RUN chmod 777 /var/www/html

# Memory limit
RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

# Update document root
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/apache2.conf
