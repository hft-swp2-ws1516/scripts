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
website_dir=$root_dir'website/'
CreateDIR $website_dir
echo 

# required
git='git'
CheckIfInstalled $git

# pull latest from GitHub
echo "Clone / Pull from GitHub:"
CloneFromGitHub $db_api_link $db_api_dir
CloneFromGitHub $crawler_link $crawler_dir
CloneFromGitHub $website_link $website_dir
echo "${DEFAULT}"
