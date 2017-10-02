#!/bin/bash


if [[ -z $1 ]]
        then
                echo "no password specify"
                postgres_password="mdppostgres";
        else
		echo "using password provided $1"
                postgres_password=$1
        fi


sudo add-apt-repository -y  ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer

# postgres
apt-get install -y postgresql-9.5
apt-get install -y  postgresql-contrib-9.5

apt-get install -y postgis postgresql-9.5-postgis-2.2

sudo /etc/init.d/postgresql start

sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$postgres_password'"
export PGPASSWORD="$postgres_password"

echo "UPDATE pg_database SET datistemplate=FALSE WHERE datname='template1';" > utf8.sql; \
	echo "DROP DATABASE template1;" >> utf8.sql; \
	echo "CREATE DATABASE template1 WITH owner=postgres template=template0 encoding='UTF8';" >> utf8.sql; \
	echo "UPDATE pg_database SET datistemplate=TRUE WHERE datname='template1';" >> utf8.sql

psql -U postgres -h localhost -a -f utf8.sql; 
rm utf8.sql

psql -U postgres -h 127.0.0.1 -c "CREATE DATABASE gisgraphy ENCODING = 'UTF8';"


psql -U postgres -h 127.0.0.1 -d gisgraphy -f /usr/share/postgresql/9.5/contrib/postgis-2.2/postgis.sql
psql -U postgres -h 127.0.0.1 -d gisgraphy -f /usr/share/postgresql/9.5/contrib/postgis-2.2/spatial_ref_sys.sql

sudo /etc/init.d/postgresql stop && sleep 20;

