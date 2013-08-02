#!/bin/bash
#install latest java 7 (manually change version variable)
# name:install_lastest_java7.sh
#http://ivan-site.com/2012/05/d...
#visit http://www.oracle.com/technetw... and determine latest update
update=7
version=7
for bitness in x64 i586; do
    #Overwrite with the latest build
    for build in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20;do
        wget --no-cookies --header "Cookie: gpw_e24=http" "http://download.oracle.com/otn...{version}u${update}-b${build}/jdk-${version}u${update}-linux-${bitness}.tar.gz"
        if [[ $bitness == 'i586' ]];then
            ourbitness="i386"
        else
            ourbitness="x86_64"
        fi
        mv jdk-${version}u${update}-linux-${bitness}.tar.gz jdk1.${version}.0_${update}-Linux-${ourbitness}
    done
done