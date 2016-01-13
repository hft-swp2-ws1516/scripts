#!/bin/sh 

# Colors
RED='\033[33;31m'
GREEN='\033[33;32m'
YELLOW='\033[33;33m'
BLUE='\033[33;34m'
DEFAULT='\033[33;0m'

clear

# check whether url exists
CheckURL() {
    if curl --output /dev/null --silent --head --fail "$1" 
    then
        echo "  $1 ${GREEN}...ok!${DEFAULT}"
    else
        echo "  $1 ${RED}...fail!${DEFAULT}"
    fi
}

# create directories
CreateDIR() {
    if [ ! -d "$1" ]
    then
        mkdir -p -- "$1"
        echo "  $1 ${YELLOW}...created!${DEFAULT}"
    else
        echo "  $1 ${GREEN}...exists!${DEFAULT}"
    fi
}

# check whether program is installed
CheckIfInstalled() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "  ${DEFAULT}I require ${YELLOW}$1 ${DEFAULT}but it's not installed. ${RED}Aborting. ${DEFAULT}"; exit 1; }
}

# Clone latest version from GitHub
CloneFromGitHub() {
    url=$1
    dir=$2 	    
    if [ "$(ls -A $2)" ]; then
        echo "  ${YELLOW}Pulling from ${DEFAULT}$1${BLUE}"
        cd $2
        echo -n "    "; git pull
    else
        echo "  ${YELLOW}Cloning from ${DEFAULT}$1${BLUE}"
        echo -n "    "; git clone $1 $2 
    fi
}

# set github project links 
echo "Check URLs:"
db_api_link=https://github.com/hft-swp2-ws1516/db-api.git
CheckURL $db_api_link
crawler_link=https://github.com/hft-swp2-ws1516/crawler.git
CheckURL $crawler_link
website_link=https://github.com/hft-swp2-ws1516/website.git
CheckURL $website_link
echo 

# create directories:
echo "Create directories:"
root_dir=$HOME'/HotCat/'
CreateDIR $root_dir
db_api_dir=$root_dir'db-api/'
CreateDIR $db_api_dir
crawler_dir=$root_dir'crawler/'
CreateDIR $crawler_dir
website_dir='/var/www/HotCat/website/'
CreateDIR $website_dir
echo 

# required
git='git'
CheckIfInstalled $git

# pull latest from GitHub
echo "Clone/Pull from GitHub:"
CloneFromGitHub $db_api_link $db_api_dir
CloneFromGitHub $crawler_link $crawler_dir
CloneFromGitHub $website_link $website_dir
echo "${DEFAULT}"

# extend / update list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 > /dev/null
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list > /dev/null

# update packages
echo -n "${BLUE}Update packages${DEFAULT}"; apt-get update > /dev/null; echo " ${GREEN}done!${DEFAULT}"

# apt-get install
echo -n "${BLUE}Install mongodb-org${DEFAULT}"; apt-get install -y mongodb-org > /dev/null ; echo " ${GREEN}done!${DEFAULT}"
echo -n "${BLUE}Install apache2${DEFAULT}"; apt-get install apache2 > /dev/null ; echo " ${GREEN}done!${DEFAULT}"
echo -n "${BLUE}Install npm${DEFAULT}"; apt-get install npm > /dev/null ; echo " ${GREEN}done!${DEFAULT}"
echo -n "${BLUE}Install python-pip${DEFAULT}"; apt-get install python-pip > /dev/null ; echo " ${GREEN}done!${DEFAULT}"

# db_api specific 
echo "${GREEN}>>> DB_API <<<"
cd $db_api_dir
npm install > /dev/null
echo "${GREEN}done!"

# crawler specific
echo "${BLUE}>>> CRAWLER <<<"
cd $crawler_dir
pip install tornado > /dev/null
pip install pymongo > /dev/null
pip install tld > /dev/null
pip install settings > /dev/null
#export PYTHONPATH=/home/hotcat/HotCat/crawler/
echo "${BLUE}done!"

# website specific
echo "${YELLOW}>>> WEBSITE <<<"
cd $website_dir
npm install --global gulp > /dev/null
npm install --save gulp-uglify > /dev/null
npm install > /dev/null
gulp build > /dev/null
echo "${YELLOW}done!"
echo ${DEFAULT}

