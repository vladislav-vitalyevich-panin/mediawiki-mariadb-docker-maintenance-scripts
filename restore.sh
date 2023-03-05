# This script restores MediaWiki backup.
# It assumes that your backup is located in the folder /backup/, which is a subfolder of the current
# execution directory.
# The backup must come from the script backup.sh

### INIT

# Prepare necessary data
DB_CONTAINER_ID=$(docker ps | grep mariadb | cut -f 1 -d ' ')
APP_CONTAINER_ID=$(docker ps | grep mediawiki | grep -v mediawiki_database | cut -f 1 -d ' ')

CONTAINER_TOOLS_PATH=./container_tools/

BACKUP_ROOT_PATH=./backup

### COPY LOGO
docker cp ./tokl_logo.png $DB_CONTAINER_ID:/var/www/html/resources/assets/tokl_logo.png

### DATABASE BACKUP UPLOAD

# Clean up the last dump
docker exec $DB_CONTAINER_ID bash -c "rm db_backup.sql"

# Upload the backup archive
docker cp $BACKUP_ROOT_PATH/db_backup/db_backup.sql.gz $DB_CONTAINER_ID:/db_backup.sql.gz

# ungzip backup
docker exec $DB_CONTAINER_ID bash -c "gunzip db_backup.sql.gz"

# Transfer tools
docker cp $CONTAINER_TOOLS_PATH/db_restore.sh $DB_CONTAINER_ID:/db_restore.sh
docker exec $DB_CONTAINER_ID bash -c "chmod 777 db_restore.sh"

# Execute database restore script
docker exec $DB_CONTAINER_ID bash -c "./db_restore.sh"


### XML DUMP AND LOCALSETTINGS

# Clean up the last dump
docker exec $APP_CONTAINER_ID bash -c "rm dump.xml"


# Upload the LocalSettings.php
docker cp $BACKUP_ROOT_PATH/LocalSettings.php $APP_CONTAINER_ID:/var/www/html/LocalSettings.php

# Upload the backup XML
docker cp $BACKUP_ROOT_PATH/xml_backup/dump.xml $APP_CONTAINER_ID:/var/www/html/dump.xml

# Restore via XML backup dump
docker exec $APP_CONTAINER_ID bash -c "php ./maintenance/importDump.php < dump.xml"

# Transfer the images backup archive
docker cp $BACKUP_ROOT_PATH/images_backup.tar.gz $APP_CONTAINER_ID:/var/www/html/

# Extract the backed up images
docker exec $APP_CONTAINER_ID bash -c "tar -xf images_backup.tar.gz"

# Clean up
docker exec $APP_CONTAINER_ID bash -c "rm images_backup.tar.gz"

# Rebuild "Recent Changes" and "Page Stats"
docker exec $APP_CONTAINER_ID bash -c "php ./maintenance/rebuildrecentchanges.php"
docker exec $APP_CONTAINER_ID bash -c "php ./maintenance/initSiteStats.php"

### END
