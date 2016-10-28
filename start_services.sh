#/bin/bash

function check_psql {
        curl picturae-ckan-postgres:5432 2>/dev/null
        if [ $? -ne 52 ]
        then
                return 1
        fi
        return 0
}

while ! check_psql
do
  echo "$(date) - still checking if docker image picturae-ckan-postgres is running on port 5432, this will not end until it is running"
  sleep 1
done
echo "$(date) - picturae-ckan-postgres is running on port 5432"

if [ ! -f /var/lib/ckan/default/db_initialized ]; then
    . /usr/lib/ckan/default/bin/activate
    cd /usr/lib/ckan/default/src/ckan
    paster db init -c /etc/ckan/default/development.ini

    if paster db init -c /etc/ckan/default/development.ini | grep -q 'SUCCES'; then
       echo "$(date) ckan database initialized"
       touch /var/lib/ckan/default/db_initialized
       echo "delete this file if you want to reinitialize the ckan database" >> /var/lib/ckan/default/db_initialized
    fi
fi

sudo service apache2 start
sudo service nginx start

while /bin/true
do
sleep 3600
done

