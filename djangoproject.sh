#!/bin/sh

PROJECTNAME=$1

mkdir $PROJECTNAME
cd $PROJECTNAME

echo "\x1B[1;31m>>>>Setting up a virtual environment... \x1B[0m"
mkvirtualenv $PROJECTNAME-env
workon $PROJECTNAME-env
add2virtualenv 'pwd'

pip -q install django

#start the project using rdegges' django skeleton
echo "\x1B[1;31m>>>>Creating a project from the skeleton... \x1B[0m"
django-admin.py startproject --template=https://github.com/rdegges/django-skel/zipball/master $PROJECTNAME

#install all the requirements of that skeleton (there are a lot)
cd $PROJECTNAME
echo "\x1B[1;31m>>>>Installing requirements...\x1B[0m"
pip -q install -r reqs/dev.txt
#postgresql
pip -q install psycopg2

chmod u+x ./manage.py

echo "\x1B[1;31m>>>>Setting up your database... \x1B[0m"
./manage.py syncdb
./manage.py migrate

echo "\x1B[1;31m>>>>Version controlling with Git... \x1B[0m"
git init
git add .
git commit -m "Auto-setup of project skeleton using rdegges/django-skel"

echo "\x1B[1;31m>>>>Prepping Heroku for production testing... \x1B[0m"
heroku create $PROJECTNAME
heroku addons:add cloudamqp:lemur heroku-postgresql:dev scheduler:standard memcache:5mb newrelic:standard pgbackups:auto-month sentry:developer
git push heroku master
heroku pg:info
read -p "\x1B[1;31m>>>>Type in the name of the database Heroku created above: \x1B[0m" db
heroku pg:promote $db
heroku config:add DJANGO_SETTINGS_MODULE=$PROJECTNAME.settings.prod
#technically pseudorandom, but damn rear random enough
SECRETKEY = cat /dev/urandom|LANG=C tr -dc "a-zA-Z0-9-_\$\?"|fold -w 40|head -1
heroku config:add SECRET_KEY=$SECRETKEY

echo "\x1B[1;31m>>>>All done! \nTo test locally: ./manage.py runserver \nTo deploy to Heroku: heroku scale web=1 && heroku ps \nTo add to GitHub: git remote add git@github.com:bjacobel/$PROJECTNAME.git\x1B[0m"