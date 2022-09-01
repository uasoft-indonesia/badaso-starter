FROM gitpod/workspace-mysql

RUN sudo apt update -y

# Install PHP 8
RUN sudo apt install -y software-properties-common
RUN sudo add-apt-repository ppa:ondrej/php -y
RUN sudo apt update -y
RUN sudo apt-get install -y php8.1-cli php8.1-dev \
    php8.1-pgsql php8.1-sqlite3 php8.1-gd \
    php8.1-curl \
    php8.1-imap php8.1-mysql php8.1-mbstring \
    php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
    php8.1-intl php8.1-readline \
    php8.1-ldap \
    php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
    php8.1-memcached php8.1-pcov php8.1-xdebug
RUN sudo php -m

# Install redis
RUN sudo apt install -y redis-server

# Install Composer 2.x
RUN sudo wget https://getcomposer.org/download/2.3.4/composer.phar
RUN sudo sudo chmod +x composer.phar
RUN sudo sudo cp composer.phar /usr/bin/composer
RUN sudo sudo mv composer.phar /usr/local/bin/composer

# Install Node Js
RUN sudo curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
RUN sudo apt -y install nodejs

USER gitpod