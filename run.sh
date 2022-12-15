#!/bin/bash

usage() {
	echo "Usage: run.sh [git-branch]"
}

if [ $# != 0 ] && [ $# != 1 ]; then
	usage
	exit -1
fi

REPOS=('rezibase')

for PROJECT in "${REPOS[@]}" 
do
	echo "⚙️  $PROJECT - GIT - clone/pull ⚙️"
	if [ ! -d $PROJECT ]; then git clone git@github.com:Cardiobase/$PROJECT.git; fi
	cd $PROJECT
	git checkout $1
	git pull
	cd ..
done

#openssl req -newkey rsa:2048 -nodes -keyout web-proxy/conf/ssl/dev.truid.ai.key -x509 -days 365 -out web-proxy/conf/ssl/dev.truid.ai.crt
#openssl req -newkey rsa:2048 -nodes -keyout web-proxy/conf/ssl/dev-api.truid.ai.key -x509 -days 365 -out web-proxy/conf/ssl/dev-api.truid.ai.crt
#openssl req -newkey rsa:2048 -nodes -keyout web-proxy/conf/ssl/dev-dashboard.truid.ai.key -x509 -days 365 -out web-proxy/conf/ssl/dev-dashboard.truid.ai.crt

for PROJECT in "${REPOS[@]}"
do
        echo "🐳 $PROJECT - DOCKER - Build Docker Image"
	docker compose build $PROJECT
	docker compose rm -fs $PROJECT
done

echo "🐳 Run all Docker Containers"
docker compose up -d

echo "🎼 Run Pending Migrations"
# docker-compose exec -w /var/www/ avocadoo chown -R www-data:www-data . # For perms
# docker-compose exec -u www-data -w /var/www/ avocadoo composer install # For vendor
docker compose exec rezibase flask db upgrade

echo "⚙️  End ⚙️"
