#!/bin/sh

# terminates script as soon as any command fails
set -e

echo "Downloading dump file from production"
curl -o latest.dump `heroku pg:backups public-url -a ampas`

echo "Restoring dev db"
bundle exec rake db:drop db:create

echo "Restoring data into db"
pg_restore --verbose --clean --no-acl --no-owner --disable-triggers -U dubilla -d ampas_development latest.dump

echo "Deleting dump file"
rm latest.dump
