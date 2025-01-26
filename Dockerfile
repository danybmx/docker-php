ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}

WORKDIR /tmp

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libmcrypt-dev \
    libzip-dev \
    git \
    zip \
    libxml2-dev \
    libpq-dev \
    libonig-dev \
    jpegoptim \
    libwebp-dev \
    curl \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    libjpeg-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    imagemagick

RUN curl -L -o /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/tags/3.7.0.tar.gz \
    && tar --strip-components=1 -vxf /tmp/imagick.tar.gz \
    && sed -i 's/php_strtolower/zend_str_tolower/g' imagick.c \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && docker-php-ext-enable imagick

RUN bash -c "if [[ \"$PHP_VERSION\" == 7.2* ]] || [[ \"$PHP_VERSION\" == 7.3* ]]; then \
    docker-php-ext-configure gd --with-gd --with-jpeg-dir; \
    else \
    docker-php-ext-configure gd --with-jpeg --with-freetype; \
    fi" \
    && bash -c "if [[ \"$PHP_VERSION\" == 7.* ]]; then \
    docker-php-ext-install xmlrpc; \
    else \
    pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3 xmlrpc && docker-php-ext-enable xmlrpc; \
    fi"

RUN docker-php-ext-install sockets mbstring gd exif zip mysqli pgsql pdo pdo_mysql pdo_pgsql soap bcmath

RUN curl --silent --show-error https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer

RUN apt-get purge -y --auto-remove \
    git \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

ENV PATH="$PATH:~/.composer/vendor/bin"

RUN echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

WORKDIR /app
