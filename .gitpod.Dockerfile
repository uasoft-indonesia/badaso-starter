FROM gitpod/workspace-mysql

RUN sudo apt update -y

# Install ppa:ondrej/php PPA
# RUN apt install -y software-properties-common
# RUN add-apt-repository ppa:ondrej/php
# RUN apt update -y

# Install PHP 8
RUN sudo apt install -y php-pear libapache2-mod-php8.0
RUN sudo apt install -y php8.0-common php8.0-cli
RUN sudo apt install -y php8.0-bz2 php8.0-zip php8.0-curl php8.0-gd php8.0-mysql php8.0-xml php8.0-dev php8.0-sqlite php8.0-mbstring php8.0-bcmath
RUN sudo php -v
RUN sudo php -m

# PHP Config
# Show PHP errors on development server.
RUN sudo sed -i -e 's/^error_reporting\s*=.*/error_reporting = E_ALL/' /etc/php/8.0/apache2/php.ini
RUN sudo sed -i -e 's/^display_errors\s*=.*/display_errors = On/' /etc/php/8.0/apache2/php.ini
RUN sudo sed -i -e 's/^zlib.output_compression\s*=.*/zlib.output_compression = Off/' /etc/php/8.0/apache2/php.ini
RUN sudo sed -i -e 's/^zpost_max_size\s*=.*/post_max_size = 32M/' /etc/php/8.0/apache2/php.ini
RUN sudo sed -i -e 's/^upload_max_filesize\s*=.*/upload_max_filesize = 32M/' /etc/php/8.0/apache2/php.ini

# Install Composer 2.2.6
RUN sudo wget https://getcomposer.org/download/2.2.6/composer.phar
RUN sudo sudo chmod +x composer.phar
RUN sudo sudo cp composer.phar /usr/bin/composer
RUN sudo sudo mv composer.phar /usr/local/bin/composer

USER gitpod
