#/bin/bash
GD_ARGS="--with-jpeg --with-freetype"
if [[ $PHP_VERSION == 7.2* ]] || [[ $PHP_VERSION == 7.3* ]]; then
    GD_ARGS="--with-gd --with-jpeg-dir"
fi
docker-php-ext-configure gd $GD_ARGS
docker-php-ext-install gd