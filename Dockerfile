FROM php:5.6-apache

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    curl \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick

# install the PHP extensions we need
RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
    pdo pdo_mysql mysqli gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install exif && \
    docker-php-ext-enable exif

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
  'https://github.com/omeka/omeka-s/releases/download/v1.4.0/omeka-s-1.4.0.zip' \
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
