FROM debian:jessie

#install needed dependencies
RUN apt-get update
RUN apt-get install sudo
RUN sudo apt-get update
RUN sudo apt-get --assume-yes install \
python-dev libpq-dev python-pip python-virtualenv \
git-core \
wget curl \
apache2 libapache2-mod-wsgi libapache2-mod-rpaf nginx

RUN sudo service apache2 start

#do we need mail?
#RUN sudo apt-get install postfix

#update pip and setup tools
RUN sudo apt-get --assume-yes remove python-setuptools
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN sudo -H python get-pip.py
RUN sudo -H pip install -U pip setuptools
RUN sudo pip install --upgrade pip
RUN sudo pip install virtualenv --upgrade

#create ckan directories
RUN sudo mkdir -p /usr/lib/ckan/default
RUN sudo chown www-data:www-data /usr/lib/ckan/default

#enter python virtual env, chain commands with && because RUN runs each command in separate shell
RUN virtualenv --no-site-packages /usr/lib/ckan/default \
&& . /usr/lib/ckan/default/bin/activate \
&& pip install --upgrade pip \
&& pip install --upgrade bleach \
&& pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.5.2#egg=ckan' \
&& pip install -r /usr/lib/ckan/default/src/ckan/requirements.txt \
&& deactivate


RUN sudo mkdir -p /etc/ckan/default
RUN sudo chown -R www-data:www-data /etc/ckan/

ADD ./development.ini /etc/ckan/default/development.ini

RUN ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini

#create apache and nginx vhosts
ADD ./apache.wsgi /etc/ckan/default/apache.wsgi
ADD ./apache_vhost.conf /etc/apache2/sites-available/ckan_default.conf
ADD ./nginx_vhost /etc/nginx/sites-available/ckan

RUN sed -i "s|Listen 80|Listen 8080|g" /etc/apache2/ports.conf

RUN sudo a2ensite ckan_default
RUN sudo a2dissite 000-default
RUN sudo rm /etc/nginx/sites-enabled/default
RUN sudo ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan_default

WORKDIR /
ADD ./start_services.sh /start_services.sh
RUN sudo chmod +x ./start_services.sh
CMD ./start_services.sh

VOLUME ["/var/lib/ckan/default"]

RUN chmod 755 -R /var/lib/ckan/default