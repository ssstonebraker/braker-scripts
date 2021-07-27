#!/bin/bash
# backup mongodb

TIMESTAMP_NOW=$(date "+%Y-%m-%d--%H-%M")
BACKUP_DEST="/backup/backups"
oldbackups="/tmp/oldbackups"
BACKUP_PATH="${BACKUP_DEST}/${TIMESTAMP_NOW}"
HOSTNAME=$(cat /etc/hostname)



##Find backups older than seven days, remove them
[ ! -d "$BACKUP_DEST" ] && /bin/mkdir -p "$BACKUP_DEST"
mkdir -p $oldbackups; find $BACKUP_DEST -type d -mtime +7 -exec mv {} $oldbackups/ \;
rm -Rf $oldbackups
#####

###CREATE BACKUP DIRECTORY IF IT DOESN'T EXIST ###
[ ! -d "$BACKUP_PATH" ] && /bin/mkdir -p "$BACKUP_PATH"


# DUMP MONGODB
cd "${BACKUP_PATH}"
echo "Starting mongodump..."
mongodump --host localhost
tar cvfz "${BACKUP_PATH}/${TIMESTAMP_NOW}-${HOSTNAME}-mongodb.tgz" dump
if [ "$?" -eq 0 ]
then
echo "mongodump Success, check ${BACKUP_PATH} for files"
else
echo "mongodump encountered a problem"
fi
rm -rf "${BACKUP_PATH}/dump"
