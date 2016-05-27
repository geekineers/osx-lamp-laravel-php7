FROM ubuntu:14.04

MAINTAINER developers@8layertech.com

ENV DEBIAN_FRONTEND noninteractive

#Set variables
ENV DBUSER=root
ENV DBPASS=root
ENV APPPORT=4567

#START: FIX OSX permissions
ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data
RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff
#END: FIX OSX permissions

#Update repo and install lamp, php, php dependencies, and phpmyadmin
RUN apt-get update && \
    apt-get -y install debconf-utils

RUN echo "mysql-server-5.5 mysql-server/root_password password $DBUSER" | debconf-set-selections && \
    echo "mysql-server-5.5 mysql-server/root_password_again password $DBPASS" | debconf-set-selections && \
    apt-get -y install mysql-server libapache2-mod-auth-mysql php5-mysql \
                        php5 libapache2-mod-php5 php5-mcrypt php5-cli \
                        curl git supervisor

RUN service mysql start
RUN service apache2 start
#RUN exec apache2 -D FOREGROUND

RUN echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/mysql/admin-user string $DBUSER" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASS" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASS" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASS" | debconf-set-selections && \
    apt-get -y install phpmyadmin

#Needs to be activated manually (that's an issue for Ubuntu 14.04)
RUN php5enmod mcrypt

COPY app.local.conf /etc/apache2/sites-available/app.local.conf

#This will only work with GNU sed
RUN sed -i.bak "s/Listen 80/Listen 80\n\nListen $APPPORT\n/" /etc/apache2/ports.conf

RUN a2ensite 000-default && \
    a2ensite app.local && \
    a2enmod rewrite

#Downloading and installing composer
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '92102166af5abdb03f49ce52a40591073a7b859a86e8ff13338cf7db58a19f7844fbc0bb79b2773bf30791e935dbd938') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#RUN php composer-setup.php
#RUN php -r "unlink('composer-setup.php');"

RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

#Laravel install
RUN composer global require "laravel/installer"

EXPOSE 80
EXPOSE 4567

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD supervisord
