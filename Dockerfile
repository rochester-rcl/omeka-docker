FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
        git \
        gnupg \
        imagemagick \
        libcurl4-gnutls-dev \
        libxml2-dev \
        libicu-dev \
        unzip \
    && docker-php-ext-install intl pdo_mysql \
    && docker-php-ext-install mysqli && docker-php-ext-enable mysqli \
    && pecl install solr-2.5.1 \
    && docker-php-ext-enable solr \
    && cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

RUN curl -J -L -s -k \
    'https://github.com/omeka/Omeka/releases/download/v2.7/omeka-2.7.zip' \
    -o /var/www/omeka.zip \
&&  unzip -q /var/www/omeka.zip -d /var/www/ \
&&  rm /var/www/omeka.zip \
&&  mv /var/www/omeka-2.7 /var/www/html/omeka

RUN curl -J -L -s -k \
  'https://github.com/scholarslab/Neatline/releases/download/v2.6.2/Neatline.zip' \
  -o /var/www/neatline.zip \
  && unzip -q /var/www/neatline.zip -d /var/www/html/omeka/plugins \
  && rm /var/www/neatline.zip

COPY ./db.ini /var/www/html/omeka/db.ini
COPY ./.htaccess /var/www/html/omeka/.htaccess
COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml

RUN curl -J -L -s -k \
  'https://github.com/omeka/omeka-s/releases/download/v3.1.1/omeka-s-3.1.1.zip' \
  -o /var/www/omeka-s.zip \
  &&  unzip -q /var/www/omeka-s.zip -d /var/www/ \
  &&  rm /var/www/omeka-s.zip \
  &&  mv /var/www/omeka-s /var/www/html/omeka-s \
  && chown -R www-data:www-data /var/www/html

COPY ./database.ini /var/www/html/omeka-s/config/database.ini
COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./omekas.htaccess /var/www/html/omeka-s/.htaccess

VOLUME /var/www/html

CMD ["apache2-foreground"]
