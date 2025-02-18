# PHP Docker image for development

[![Build & Publish](https://github.com/danybmx/docker-php/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/danybmx/docker-php/actions/workflows/build.yml)

**Disclaimer:** This image is intended for development purposes. Do not use in production
and create your own based on the official but with only the libraries you need. Use the
Dockerfiles as an example of how to install the libraries in different ways.

Based on official php images but including **[docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)** script and **composer**

## Apache defaults

The default apache docroot is `/var/www/html/public` this makes that most of the frameworks
works by default when copying them to `/var/www/html`.

If you are using tools like wordpress that doesn't include the public on their file structure
just copy the content inside `/var/www/html/public`.

## Apache config

The config file is placed on `/etc/apache2/apache2.conf`.

## PHP default

It goes with all PHP distribution defaults except for memory which it defaults to 512MB.
