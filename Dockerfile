ARG PHP_VERSION=8.4
ARG MEMORY_LIMIT=512M
ARG IMAGICK_VERSION=3.7.0

FROM php:${PHP_VERSION}-apache

# PHP Extensions
RUN cd /tmp
ARG IMAGICK_VERSION
ENV IMAGICK_VERSION=${IMAGICK_VERSION}
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libmcrypt-dev \
    libzip-dev \
    git \
    zip \
    libxml2-dev \
    libpq-dev \
    libonig-dev \
    imagemagick \
    jpegoptim \
    libwebp-dev \
    curl \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    libmagickwand-dev \
    libjpeg-dev \
    && curl -L -v -o /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/tags/${IMAGICK_VERSION}.tar.gz \
    && tar --strip-components=1 -vxf /tmp/imagick.tar.gz \
    && sed -i 's/php_strtolower/zend_str_tolower/g' imagick.c \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && docker-php-ext-enable imagick \
    && bash -c "if [[ \"$PHP_VERSION\" == 7.2* ]] || [[ \"$PHP_VERSION\" == 7.3* ]]; then \
    docker-php-ext-configure gd --with-gd --with-jpeg-dir; \
    else \
    docker-php-ext-configure gd --with-jpeg --with-freetype; \
    fi" \
    && bash -c "if [[ \"$PHP_VERSION\" == 7.* ]]; then \
    docker-php-ext-install xmlrpc; \
    else \
    pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3 xmlrpc && docker-php-ext-enable xmlrpc; \
    fi" \
    && docker-php-ext-install sockets mbstring gd exif zip mysqli pgsql pdo pdo_mysql pdo_pgsql soap bcmath \
    && curl --silent --show-error https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && apt-get purge -y --auto-remove \
    git \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

ENV PATH="$PATH:~/.composer/vendor/bin"

# Apache Extensions
RUN a2enmod headers rewrite expires deflate
# Memory limit
RUN echo "memory_limit = ${MEMORY_LIMIT}" >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

# Update document root
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/apache2.conf

USER www-data
WORKDIR /var/www/html