FROM php:7.1-apache

RUN apt-get update && apt-get install --no-install-recommends  -y \
    pkg-config \
    mysql-client \
    bash-completion \
    imagemagick \
    libmemcached-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng12-dev \
    libjpeg-dev \
    libicu-dev \
    libbz2-dev \
    libxslt-dev \
    libldap2-dev \
    zlib1g-dev \
    mcrypt \
    unzip \
    wget

RUN apt-get update -y \
  && apt-get install -y \
    libxml2-dev \
    php-soap \
  && apt-get clean -y \
  && docker-php-ext-install soap

#PHP Extensions
RUN pecl install xdebug && docker-php-ext-enable xdebug \
  && printf "\n" | pecl install imagick && docker-php-ext-enable imagick \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mbstring zip bcmath intl exif fileinfo \
  && docker-php-ext-enable opcache

RUN apt-get update && apt-get install --yes --no-install-recommends \
    libssl-dev

RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

#Set the timezone.
RUN echo "Europe/Warsaw" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

#XDEBUG
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini

RUN echo "pcre.jit=0" >> /usr/local/etc/php/php.ini

RUN a2enmod rewrite

#COMPOSER
RUN wget https://getcomposer.org/download/1.4.1/composer.phar -O /usr/bin/composer && chmod +x /usr/bin/composer
RUN mkdir /composer

#VIM
RUN apt-get install -y vim
#NET-TOOLS
RUN apt-get install -y net-tools

# SET APACHE DOCUMENT ROOT
ENV DOCUMENT_ROOT /var/www/html
RUN sed -ri -e 's!/var/www/html!${DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get clean && rm -rf /vsar/lib/apt/lists/* /tmp/* /var/tmp/*
