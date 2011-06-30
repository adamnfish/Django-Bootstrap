#! /bin/bash

# This file is a django-bootstrap utility. It sets up a project the
# way I want it because I find myself running through these same steps
# every time (which is frustrating)!
#
# It's very easy to create a "Hello, World!"-level project in Django,
# but getting up and running on a real project is considerably more
# effort. This project is designed to overcome this barrier.
#
# Please fork this on github and help me make the perfect tool for
# getting up and running with a *real* Django project quickly and
# easily.
#
# Use this project for anything you like, fork it, modify it etc.

function help {
    echo "Usage: `basename $0` <project_name> <dirname>"
}

# check args and provide help if incorrect
if [ $# != 2 ]; then
    help
    exit
fi

# check if the dir already exists
if [ -d $2 ]; then
    echo "That directory ("$2") already exists"
    exit
fi

# otherwise we can run the bootstrap

# install dependencies
# virtualenv

# create a parent dir variable so we can cd back to it if necessary
parent_dir=`pwd`
project_dir=$2
project_name=$1

# create the project dir
mkdir $project_dir
cd $project_dir

# git setup
git init
echo -e "*.pyc\nvenv\ndb\n\n*~\n*#\n.project\n.pydevproject\n" > .gitignore
git add .gitignore
git commit -m "Initial commit"

# setup python environment
virtualenv venv --no-site-packages

# write an initial requirements file
echo -e "django\nsouth\n" > requirements.txt
venv/bin/pip install -r requirements.txt

# create additional root-level files
echo $project_name > README
touch LICENCE

# create a project therein using django in a source directory
venv/bin/python venv/bin/django-admin.py startproject $project_dir

# create file dirs
mkdir -p files/static
mkdir -p files/restricted
mkdir -p files/private

# edit the settings file
# imports
sed -i "s/DEBUG = True/import os\nimport sys\n\nPROJECT_DIR = <project dir>\nPROJECT_ROOT = os.path.dirname(PROJECT_DIR)\n\nDEBUG = True/" $project_dir/settings.py
# db
sed -i "s/'ENGINE': 'django.db.backends.',.*$/'ENGINE': 'django.db.backends.sqlite3',/" $project_dir/settings.py
sed -i "s/'NAME': '',.*$/'NAME': os.path.join(PROJECT_ROOT, 'db'),/" $project_dir/settings.py
# location
sed -i "s/TIME_ZONE = '[^']*'/TIME_ZONE = 'Europe\/London'/" $project_dir/settings.py
sed -i "s/LANGUAGE_CODE = '[^']*'/LANGUAGE_CODE = 'en-gb'/" $project_dir/settings.py
# files
sed -i "s/MEDIA_ROOT = '[^']*'/MEDIA_ROOT = os.path.join(PROJECT_ROOT, 'files', 'restricted')/" $project_dir/settings.py
sed -i "s/MEDIA_URL = '[^']*'/MEDIA_URL = '\/media\/'/" $project_dir/settings.py
sed -i "s/STATIC_ROOT = '[^']*'/STATIC_ROOT = os.path.join(PROJECT_ROOT, 'files', 'static')/" $project_dir/settings.py
sed -i "s/STATIC_URL = '[^']*'/STATIC_URL = '\/static\/'/" $project_dir/settings.py
sed -i "s/ADMIN_MEDIA_PREFIX = '[^']*'/ADMIN_MEDIA_PREFIX = '\/static\/admin\/'/" $project_dir/settings.py
# installed apps
sed -i "s/    # 'django.contrib.admindocs',/    # 'django.contrib.admindocs',\n    'south'/" $project_dir/settings.py
# templates
sed -i "s/TEMPLATE_DIRS = (/TEMPLATE_DIRS = (\n    os.path.join(PROJECT_DIR, 'templates'),/" $project_dir/settings.py

# create an sqlite db for the project
touch db

# create a tests dir
mkdir tests
echo "This package holds the testsuite for "$project_name > tests/README

# git commit post-bootstrap
git add -A
git commit -m "Bootstrapped project - initial commit"

echo "Django project has been bootstrapped"
echo "You should now:"
echo "  1. Set the ADMINS variable in "$project_dir"/settings to include your name and email"
echo "  2. I've not added the PROJECT_DIR setting yet, so this will need to be set"
echo "  3. If you aren't using sqlite then the database settings will need changing"
echo "  4. The STATICFILES settings are not customised yet"
echo "  5. This project is already tracked in git but yuo may wish to add your own remotes"
echo "Good luck!"
