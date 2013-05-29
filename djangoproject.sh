#!/bin/bash

PROJECTNAME=$1

echo -e "\x1B[1;31m>>>> Setting up a virtual environment... \x1B[0m"
export WORKON_HOME=~/Envs
mkdir -p $WORKON_HOME
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv $PROJECTNAME-env
workon $PROJECTNAME-env
add2virtualenv 'pwd'

echo -e "\x1B[1;31m>>>> Installing the latest Django... \x1B[0m"
pip install django

#start the project using rdegges' django skeleton
echo -e "\x1B[1;31m>>>> Creating a project from the skeleton... \x1B[0m"
django-admin.py startproject --template=https://github.com/rdegges/django-skel/zipball/master $PROJECTNAME

#install all the requirements of that skeleton (there are a lot)
cd $PROJECTNAME
echo -e "\x1B[1;31m>>>> Installing requirements...\x1B[0m"
pip install -r reqs/dev.txt

#postgresql needs to be installed frm src, pip's version is broken on OSX
#download the most recent from github
curl https://codeload.github.com/psycopg/psycopg2/zip/master > psycopg2.zip #OSX doesn't have wget???
unzip -q psycopg2.zip
cd psycopg2-master
easy_install .
cd ../
rm -rf psycopg2*

chmod u+x ./manage.py

echo -e "\x1B[1;31m>>>> Setting up your database... \x1B[0m"
echo -e "\x1B[1;31m>>>> You'll need to provide a username/password for an admin account. \x1B[0m"
./manage.py syncdb
./manage.py migrate

mkdir assets
mkdir assets/{css,js,img}

echo -e "\x1B[1;31m>>>> Version controlling with Git... \x1B[0m"
git init
git add .
git commit -m "Auto-setup of project skeleton using rdegges/django-skel"

echo -e "\x1B[1;31m>>>> Prepping for Heroku production testing... \x1B[0m"
heroku create $PROJECTNAME
heroku addons:add cloudamqp:lemur heroku-postgresql:dev memcachier:dev scheduler:standard newrelic:standard pgbackups:auto-month sentry:developer
echo -e "\x1B[1;31m>>>> Pushing to Heroku and installing requirements...\x1B[0m"
git push heroku master
heroku pg:info
echo -e "\x1B[1;31m>>>> Type in the name of the database Heroku created above: \x1B[0m"
read -p "Database name?: " db
heroku pg:promote $db
heroku config:add DJANGO_SETTINGS_MODULE=$PROJECTNAME.settings.prod
#technically pseudorandom, but damn near random enough
SECRETKEY=`cat /dev/urandom|LANG=C tr -dc "a-zA-Z0-9-_\$\?"|fold -w 40|head -1`
heroku config:add SECRET_KEY=$SECRETKEY

# y'all can have my public S3 access key if you want
heroku config:add AWS_ACCESS_KEY_ID=AKIAJCJ7UQVOTIBRMJEQ
heroku config:add AWS_STORAGE_BUCKET_NAME=$PROJECTNAME

exitmessage="\x1B[1;31m>>>> All done! \nTo test locally:\tworkon "$PROJECTNAME"-env\n\t\t\tdjango runserver \nTo run on Heroku:\theroku ps:scale web=1\n\t\t\theroku ps\n\t\t\theroku open\nTo add to GitHub:\tgit remote add git@github.com:bjacobel/"$PROJECTNAME".git\nTo add S3 storage:\theroku config:add AWS_SECRET_ACCESS_KEY_ID=xxx\n\t\t\tthen create a bucket named the same as this project on S3\x1B[0m"
echo -e $exitmessage