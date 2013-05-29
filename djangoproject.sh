#!/bin/bash

PROJECTNAME=$1

echo -e "\x1B[1;31m>>>>Setting up a virtual environment... \x1B[0m"
export WORKON_HOME=~/Envs
mkdir -p $WORKON_HOME
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv $PROJECTNAME-env
workon $PROJECTNAME-env
add2virtualenv 'pwd'

echo -e "\x1B[1;31m>>>>Installing the latest Django... \x1B[0m"
pip install django

#start the project using rdegges' django skeleton
echo -e "\x1B[1;31m>>>>Creating a project from the skeleton... \x1B[0m"
django-admin.py startproject --template=https://github.com/rdegges/django-skel/zipball/master $PROJECTNAME

#install all the requirements of that skeleton (there are a lot)
cd $PROJECTNAME
echo -e "\x1B[1;31m>>>>Installing requirements...\x1B[0m"
pip install -r reqs/dev.txt
#postgresql causes problems
#pip install psycopg2

chmod u+x ./manage.py

echo -e "\x1B[1;31m>>>>Setting up your database... \x1B[0m"
echo -e "\x1B[1;31m>>>>You might need to provide a username/password. \x1B[0m"
./manage.py syncdb
./manage.py migrate

echo -e "\x1B[1;31m>>>>Version controlling with Git... \x1B[0m"
git init
git add .
git commit -m "Auto-setup of project skeleton using rdegges/django-skel"

echo -e "\x1B[1;31m>>>>Prepping for Heroku production testing... \x1B[0m"
cd $PROJECTNAME
heroku create $PROJECTNAME
#heroku wants a credit card to be able to add any addons... fake-ass bitche$$
#heroku addons:add cloudamqp:lemur heroku-postgresql:dev scheduler:standard memcache:5mb newrelic:standard pgbackups:auto-month sentry:developer
#just do postgresql for now
heroku addons:add heroku-postgresql:dev
git push heroku master
heroku pg:info
echo -e "\x1B[1;31m>>>>Type in the name of the database Heroku created above: \x1B[0m"
read -p "Database name?: " db
heroku pg:promote $db
heroku config:add DJANGO_SETTINGS_MODULE=$PROJECTNAME.settings.prod
#technically pseudorandom, but damn rear random enough
SECRETKEY = cat /dev/urandom|LANG=C tr -dc "a-zA-Z0-9-_\$\?"|fold -w 40|head -1
heroku config:add SECRET_KEY=$SECRETKEY

message1="\x1B[1;31m>>>>All done! \nTo test locally: \t./manage.py runserver \nTo deploy to Heroku: \tgit push heroku master && heroku scale web=1 && heroku ps \nTo add to GitHub: \tgit remote add git@github.com:bjacobel/"
message2=".git\x1B[0m"
message=$message1$PROJECTNAME$message2

echo -e $message