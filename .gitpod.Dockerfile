FROM gitpod/workspace-mysql

RUN sudo apt update -y

# Install ppa:ondrej/php PPA
RUN sudo apt install -y software-properties-common
RUN sudo add-apt-repository ppa:ondrej/php -y
RUN sudo apt update -y

# Install PHP 8
RUN sudo apt install -y php-pear libapache2-mod-php
RUN sudo apt install -y php-common php-cli
RUN sudo apt install -y php-bz2 php-zip php-curl php-gd php-mysql php-xml php-dev php-mbstring php-bcmath
RUN sudo php -v
RUN sudo php -m

# Install Composer 2.2.6
RUN sudo wget https://getcomposer.org/download/2.2.6/composer.phar
RUN sudo sudo chmod +x composer.phar
RUN sudo sudo cp composer.phar /usr/bin/composer
RUN sudo sudo mv composer.phar /usr/local/bin/composer

# Init Database
RUN mysql -u root -e "create database badaso"

USER gitpod
