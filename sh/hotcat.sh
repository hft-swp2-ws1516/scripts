#!/bin/sh 

# DEFINE COLORS
RED='\033[33;31m'
GREEN='\033[33;32m'
YELLOW='\033[33;33m'
BLUE='\033[33;34m'
DEFAULT='\033[33;0m'

if [ "$(id -u)" != "0" ]; then
    echo "|--------------------------------------------------------------------------------|"
    echo "${DEFAULT}|- ${YELLOW}Sorry${DEFAULT}, ${YELLOW}you are not root${DEFAULT}."
    echo "${DEFAULT}|- ${YELLOW}Use${DEFAULT}: sudo"
    echo "${DEFAULT}|- ${RED}Aborting${DEFAULT}."
    echo "|--------------------------------------------------------------------------------|"
    exit 1
fi

clear
### START METHOD DECLARATION
# checks whether url exists
CheckURL() {
    if curl --output /dev/null --silent --head --fail "$1" 
    then
        echo -n
        #echo "  $1 ${GREEN}...ok!${DEFAULT}"
    else
        echo "  $1 ${RED}...fail!${DEFAULT}"
        exit 1
    fi 
}

# create directory with premission 0777
CreateDIR() {
    if [ ! -d "$1" ]
    then 
        sudo install -d -m 0777 $1
    fi
}

# check whether program is installed
CheckIfInstalled() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "|- ${DEFAULT}I require ${YELLOW}$1 ${DEFAULT}but it's not installed. ${RED}Aborting.${DEFAULT}"; 
    exit 1; }
}

# Clone or Pull from GitHub
CloneFromGitHub() {
    url=$1
    dir=$2 	    
    if [ "$(ls -A $2)" ]; then
        echo -n "|- ${YELLOW}Pulling from ${DEFAULT}$1${DEFAULT}"
        cd $2
        { sudo git pull --quiet; } > /dev/null 2>&1
        echo " ${GREEN}done!${DEFAULT}"
    else
        echo -n "|- ${YELLOW}Cloning from ${DEFAULT}$1${DEFAULT}"
        { sudo git clone $1 $2 --quiet; } > /dev/null 2>&1
        echo " ${GREEN}done!${DEFAULT}" 
    fi
}

# install apt-get
AptGetInstall() {
    echo -n "|- ${DEFAULT}apt-get install ${YELLOW}$1"
    if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        { sudo apt-get install -y $1;} > /dev/null 2>&1
        echo " ${GREEN}done!${DEFAULT}"
    else
        echo " ${GREEN} already installed.${DEFAULT}"    
    fi
}

# install pip
PipInstall() {
    echo -n "|- ${DEFAULT}pip install ${YELLOW}$1"
    sudo pip install $1 > /dev/null 
    echo " ${GREEN}done!${DEFAULT}"    
}
### END METHOD DECLARATION

### START
echo "|--------------------------------------------------------------------------------|"
echo "|                                Installing HotCat                               |"
echo "|--------------------------------------------------------------------------------|"
echo "|                                                                                |"

# check github urls
echo "|- Checking GitHub URLs.                                                         |"
db_api_link=https://github.com/hft-swp2-ws1516/db-api.git
CheckURL $db_api_link
crawler_link=https://github.com/hft-swp2-ws1516/crawler.git
CheckURL $crawler_link
website_link=https://github.com/hft-swp2-ws1516/website.git
CheckURL $website_link

# create directories
echo "|- Creating directories.                                                        |"
root_dir=$HOME'/HotCat/'
CreateDIR $root_dir
db_api_dir=$root_dir'db-api/'
CreateDIR $db_api_dir
crawler_dir=$root_dir'crawler/'
CreateDIR $crawler_dir
website_dir='/var/www/HotCat/website/'
CreateDIR '/var/www/'
CreateDIR '/var/www/HotCat/'
CreateDIR $website_dir
echo "|                                                                                |"
echo "|--------------------------------------------------------------------------------|"

# required
git='git'
CheckIfInstalled $git

### START GitHub
echo "|                                                                                |"
echo "|- GitHub:                                                                       |"
CloneFromGitHub $db_api_link $db_api_dir
CloneFromGitHub $crawler_link $crawler_dir
CloneFromGitHub $website_link $website_dir
echo -n "${DEFAULT}"
### END GitHub


### START INSTALL PACKAGES 
echo "|                                                                                |"
echo "|--------------------------------------------------------------------------------|"
echo "|                                                                                |"
echo "|- Installing packages:                                                          |"
# Mongo-DB
{ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927; } > /dev/null 2>&1
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list > /dev/null 
echo -n "|- Update packages"; 
sudo apt-get update > /dev/null; 
echo " ${GREEN}done!${DEFAULT}"
AptGetInstall 'mongodb-org'
AptGetInstall 'python-pip'
AptGetInstall 'npm'
AptGetInstall 'apache2'
AptGetInstall 'node'
### END INSTALL PACKEGES

### START DB_API specific 
echo "|                                                                                |"
echo "|--------------------------------------------------------------------------------|"
echo "|                                                                                |"
echo "|- DB_API:                                                                       |"
cd $db_api_dir
echo -n "${DEFAULT}|- npm install"
{ sudo npm install; } > /dev/null 2>&1
echo " ${GREEN}done!${DEFAULT}"    
cd
### END DB_API specific

### START CRAWLER specific
echo "|                                                                                |"
echo "|--------------------------------------------------------------------------------|"
echo "|                                                                                |"
echo "|- CRAWLER:                                                                      |"
cd $crawler_dir
PipInstall 'pymongo' 
PipInstall 'request'
PipInstall 'tornado'
PipInstall 'tld'
PipInstall 'lxml'
cd
### END CRAWLER


### WEBSITE specific
echo "|                                                                                |"
echo "|--------------------------------------------------------------------------------|"
echo "|                                                                                |"
echo "|- WEBSITE:                                                                      |"
cd $website_dir

#1
echo -n "${DEFAULT}|- npm install --global gulp"
{ sudo npm install --global gulp; } > /dev/null 2>&1
echo " ${GREEN}done!${DEFAULT}"

#2
echo -n "${DEFAULT}|- npm install --save gulp-uglify"
{ sudo npm install --save gulp-uglify; } > /dev/null 2>&1
echo " ${GREEN}done!${DEFAULT}"

#3
echo -n "${DEFAULT}|- npm install"
{ sudo npm install; } > /dev/null 2>&1
echo " ${GREEN}done!${DEFAULT}"   
 
#4
echo -n "${DEFAULT}|- gulp build"
{ sudo gulp build; } > /dev/null 2>&1
echo " ${GREEN}done!${DEFAULT}"    
cd
### END WEBSITE

# Doublecheck List
CheckIfInstalled 'mongo'

# FOOTER
echo "|                                                                                |"
echo "|--------------------------------------------------------------------------------|"
echo "|                                                                                |"
echo "| HFT Stuttgart:   http://www.hft-stuttgart.de/                                  |"
echo "| GitHub:          https://github.com/hft-swp2-ws1516                            |"
echo "|                                                                                |"
echo "| run crawler:     $ python hotcat.py                                            |"
echo "| run api:         $ nodejs api.js                                               |"
echo "| website:         file:///var/www/HotCat/website/src/index.html                 |"
echo "|                                                                                |"
echo "|--------------------------------------------------------------------------------|"
echo ${DEFAULT}


