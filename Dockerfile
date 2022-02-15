# reference from https://github.com/jabardigitalservice/docker-phpfpm-nginx
FROM alpine:latest

ADD https://packages.whatwedo.ch/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN apk --update-cache add ca-certificates

# Install packages
RUN apk --no-cache add php8 php8-fpm php8-opcache php8-openssl php8-curl \
    nginx supervisor curl php8-json php8-phar php8-iconv \
    php8-exif php8-sodium php8-pdo php8-mbstring php8-dom \
    php8-zip php8-mysqli php8-sqlite3 php8-session php8-bcmath \
    php8-common php8-gd php8-intl php8-fileinfo php8-pdo_mysql \
    php8-tokenizer php8-xml php8-xmlwriter php8-simplexml \
    php8-ctype php8-xmlreader nodejs npm

RUN ln -s /usr/bin/php8 /usr/bin/php

# install composer
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Configure nginx
COPY docker/config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP
RUN mkdir -p /run/php/
RUN touch /run/php/php8.0-fpm.pid

# Configure PHP-FPM
COPY docker/config/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY docker/config/php.ini /etc/php8/conf.d/custom.ini

# Configure supervisord
COPY docker/config/supervisord.conf /etc/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/badaso

# Add application
WORKDIR /var/www/badaso
COPY --chown=nobody . /var/www/badaso/
# COPY .env.example .env

RUN composer install --prefer-dist --no-ansi --no-interaction --no-progress --no-scripts

RUN chmod -R 755 /var/www/badaso/storage
RUN chmod -R 755 /var/www/badaso/public

RUN composer dump-autoload

RUN php artisan key:generate
RUN php artisan config:clear
RUN php artisan cache:clear
RUN php artisan view:clear
RUN php artisan route:clear
RUN php artisan stroage:link
RUN php artisan badaso:setup

RUN npm install -g yarn
RUN yarn && yarn prod

RUN chown -R nobody.nobody /var/www/badaso && \
    chown -R nobody.nobody /run && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody
# USER root

# Expose the port nginx is reachable on
EXPOSE 8080
EXPOSE 443

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
