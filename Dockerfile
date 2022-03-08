FROM ubuntu:21.10

LABEL maintainer="Taylor Otwell"

ARG WWWGROUP
ARG NODE_VERSION=16

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu impish main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.1-cli php8.1-dev \
    php8.1-pgsql php8.1-sqlite3 php8.1-gd \
    php8.1-curl \
    php8.1-imap php8.1-mysql php8.1-mbstring \
    php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
    php8.1-intl php8.1-readline \
    php8.1-ldap \
    php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
    php8.1-memcached php8.1-pcov php8.1-xdebug \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn \
    # && apt-get install -y mysql-client \
    # && apt-get install -y postgresql-client \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.1

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
COPY .env.example .env

RUN composer install --prefer-dist --no-ansi --no-interaction --no-progress --no-scripts

RUN chmod -R 755 /var/www/badaso/storage
RUN chmod -R 755 /var/www/badaso/public

# RUN composer dump-autoload

# RUN php artisan key:generate
# RUN php artisan config:clear
# RUN php artisan cache:clear
# RUN php artisan view:clear
# RUN php artisan route:clear
# RUN php artisan storage:link
# RUN php artisan badaso:setup

# RUN yarn && yarn prod

# Switch to use a non-root user from here on
USER root

# Expose the port nginx is reachable on
EXPOSE 8000
EXPOSE 443

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
