#!/bin/bash
#
# Author: Steve Stonebraker
# Name: install_oracle_jdk_6u45.sh
# Date: 7/22/2013
#
# Description: This script will install the Oracle JDK 
#              on a newly spun up Ubuntu Server
#
################################################
# Install the Oracle JDK
################################################
#
# SET PARAMS
apt-get purge -y openjdk*
JDK_FILE="jdk-6u45-linux-x64.bin"
JDK_URL="http://download.oracle.com/otn-pub/java/jdk/6u45-b05/$JDK_FILE"
JVM_VER="jdk1.6.0_45"
DIR_JVM="/usr/lib/jvm/"
ORACLE_COOKIE="Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F"

# Download and install jdk
sudo mkdir /sjava && cd /sjava
sudo wget --quiet --no-cookies --header "${ORACLE_COOKIE}" "${JDK_URL}"
sudo chmod a+x ${JDK_FILE}
yes | sudo ./${JDK_FILE}

sudo mkdir -p ${DIR_JVM}
sudo mv ${JVM_VER} ${DIR_JVM}	
 
for binary in $(ls ${DIR_JVM}${JVM_VER}/bin/j*); do
    name=$(basename $binary)
    sudo update-alternatives --install /usr/bin/${name} ${name} ${binary} 1
    sudo update-alternatives --set ${name} ${binary}
done

#cleanup
sudo rm "${JDK_FILE}"