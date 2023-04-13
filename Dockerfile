ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-apache

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
        libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Imagic
RUN pecl install imagick && docker-php-ext-enable imagick

# GD
RUN bash -c "if [[ \"$PHP_VERSION\" == 7.2* ]] || [[ \"$PHP_VERSION\" == 7.3* ]]; then \
        docker-php-ext-configure gd --with-gd --with-jpeg-dir; \
    else \
        docker-php-ext-configure gd --with-jpeg --with-freetype; \
    fi"

# XMLRPC
RUN bash -c "if [[ \"$PHP_VERSION\" == 7.* ]]; then \
        docker-php-ext-install xmlrpc; \
    else \
        pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3 xmlrpc && docker-php-ext-enable xmlrpc; \
    fi"

RUN docker-php-ext-install \
    mbstring \
    gd \
    exif \
    zip \
    mysqli \
    pgsql \
    pdo pdo_mysql pdo_pgsql \
    soap \
    bcmath

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
