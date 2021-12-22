#/bin/bash -l
#
# Author: Steve Stonebraker
# Date: 2/07/2019
# Source: http://brakertech.com/script-to-backup-alienvault-ossim-master-server/
# Script name: backup_ossim_server.sh
#
# Backup Script purpose, to backup:
# 1. MySQL
# 2. MongoDB
# 3. AlienVault OSSIM Config
# 4. AlienVault environment directories
#
# Requirement:
# User must set values in section below or all backups will 
# be placed in /backup/backups
#
# How to use: Place script in cron to run daily
# Note: Cron must have proper SHELL and PATH defined
# e.g.
# SHELL=/bin/bash
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

###USER MUST SET FOR SERVER ###
BACKUP_DEST="/backup/backups"
OSSIM_VERSION=$(dpkg -l | grep ossim-cd-tools | awk '{print $3}' | awk -F'-' '{ print $1 }')
OSSIM_HOSTNAME=$(cat /etc/hostname)
OSSIM_MYSQLPW=$(grep ^pass /etc/ossim/ossim_setup.conf | sed 's/pass=//')
TIMESTAMP_NOW=$(date "+%Y-%m-%d--%H-%M")
oldbackups="/tmp/oldbackups"
BACKUP_PATH="${BACKUP_DEST}/${TIMESTAMP_NOW}"
#################################


##Find backups older than seven days, remove them
[ ! -d $BACKUP_DEST ] && /bin/mkdir -p $BACKUP_DEST
mkdir -p $oldbackups; find $BACKUP_DEST -type d -mtime +7 -exec mv {} $oldbackups/ \;
rm -Rf $oldbackups
#####


###CREATE BACKUP DIRECTORY IF IT DOESN'T EXIST, REMOVE IF IT DOES ###
[ ! -d $BACKUP_PATH ] && /bin/mkdir -p $BACKUP_PATH || /bin/rm -f $BACKUP_PATH/*

# stop services
echo "Stopping Services"
/etc/init.d/monit stop
/etc/init.d/ossim-server stop
/etc/init.d/ossim-agent stop
/etc/init.d/ossim-framework stop
/etc/init.d/alienvault-api stop

# DUMP MYSQL
echo "dumping mysql... this could take a while... "
cd ${BACKUP_PATH}
mysqldump -p${OSSIM_MYSQLPW} \
--no-autocommit \
--single-transaction \
--all-databases \
| pigz > ${BACKUP_PATH}/${TIMESTAMP_NOW}-${OSSIM_HOSTNAME}-OSSIM_${OSSIM_VERSION}-alienvault-mysql-all-dbs.sql.gz

if [ "$?" -eq 0 ]
then
    echo "Mysqldump Success, check ${BACKUP_PATH} for files"
else
    echo "Mysqldump encountered a problem"
fi

# DUMP MONGODB
cd ${BACKUP_PATH}
echo "Starting mongodump..."
mongodump --host localhost
tar cvfz ${BACKUP_PATH}/${TIMESTAMP_NOW}-${OSSIM_HOSTNAME}-OSSIM_${OSSIM_VERSION}-alienvault-mongodb.tgz dump
if [ "$?" -eq 0 ]
then
    echo "mongodump Success, check ${BACKUP_PATH} for files"
else
    echo "mongodump encountered a problem"
fi
rm -rf ${BACKUP_PATH}/dump

# Backup Environment

# Create uuid file if not exist
 if [[ ! -f /etc/alienvault-center/alienvault-center-uuid ]]; then dmidecode - s system-uuid | awk '{print tolower($0)}' > /etc/alienvault-center/alienvault-center-uuid ; fi

# Backup Environment Files
tar -czf ${BACKUP_PATH}/${TIMESTAMP_NOW}-${OSSIM_HOSTNAME}-OSSIM_${OSSIM_VERSION}-alienvault-environment.tgz /etc/ /root/ /home/ /var/log/ /var/ossec/ /usr/share/ /var/ossim/keys/ /var/nfsen/ /var/alienvault/ /var/backups/ 


if [ "$?" -eq 0 ]
then
    echo "tar gzip Success, check ${BACKUP_PATH} for files"
else
    echo "tar gzip encountered a problem"
fi

# Start services
echo "Starting Services"
/etc/init.d/monit start
/etc/init.d/ossim-server start
/etc/init.d/ossim-agent start
/etc/init.d/ossim-framework start
/etc/init.d/alienvault-api start