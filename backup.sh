
# This script backs up mediawiki data (database, XML, images, LocalSettings.php).
# The save location is /mnt/$BACKUP_VOLUME/mediawiki_backup/$CURRENT_TIMESTAMP/
# $BACKUP_VOLUME is your backup volume (without slashes), and $CURRENT_TIMESTAMP
# is the timestamp of the time when the backup was done.

### INIT
BACKUP_VOLUME=HC_Volume_28787811

# Prepare necessary data
DB_CONTAINER_ID=$(docker ps | grep mariadb | cut -f 1 -d ' ')
APP_CONTAINER_ID=$(docker ps | grep mediawiki | grep -v mediawiki_database | cut -f 1 -d ' ')

CONTAINER_TOOLS_PATH=./container_tools/

CURRENT_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p /mnt/$BACKUP_VOLUME/mediawiki_backup/$CURRENT_TIMESTAMP/db_backup
mkdir -p /mnt/$BACKUP_VOLUME/mediawiki_backup/$CURRENT_TIMESTAMP/xml_backup

### DATABASE BACKUP

# Transfer tools
docker cp $CONTAINER_TOOLS_PATH/db_dumper.sh $DB_CONTAINER_ID:/db_dumper.sh
docker cp $CONTAINER_TOOLS_PATH/db_dumper_cleanup.sh $DB_CONTAINER_ID:/db_dumper_cleanup.sh

docker exec $DB_CONTAINER_ID bash -c "chmod 777 db_dumper_cleanup.sh"
docker exec $DB_CONTAINER_ID bash -c "chmod 777 db_dumper.sh"

# Clean up the last dump
docker exec $DB_CONTAINER_ID bash -c "./db_dumper_cleanup.sh"

# Execute dumper
docker exec $DB_CONTAINER_ID bash -c "./db_dumper.sh"

# Copy the dump to our backup location
docker cp $DB_CONTAINER_ID:/db_backup.sql.gz /mnt/$BACKUP_VOLUME/mediawiki_backup/$CURRENT_TIMESTAMP/db_backup/

### IMAGES BACKUP, XML DUMP AND LOCALSETTINGS

# Get the LocalSettings.php
docker cp $APP_CONTAINER_ID:/var/www/html/LocalSettings.php /mnt/$BACKUP_VOLUME/mediawiki_backup/$CURRENT_TIMESTAMP/

# Tar and GZip the images
docker exec $APP_CONTAINER_ID bash -c "tar -zcvf images_backup.tar.gz images/"

# Get the images archive
docker cp $APP_CONTAINER_ID:/var/www/html/images_backup.tar.gz /mnt/$BACKUP_VOLUME/mediawiki_backup/$CURRENT_TIMESTAMP/

# Clean up
docker exec $APP_CONTAINER_ID bash -c "rm images_backup.tar.gz"

# Transfer tools
docker cp $CONTAINER_TOOLS_PATH/xml_dumper.sh $APP_CONTAINER_ID:/var/www/html/xml_dumper.sh
docker cp $CONTAINER_TOOLS_PATH/xml_dumper_cleanup.sh $APP_CONTAINER_ID:/var/www/html/xml_dumper_cleanup.sh

docker exec $APP_CONTAINER_ID bash -c "chmod 777 xml_dumper_cleanup.sh"
docker exec $APP_CONTAINER_ID bash -c "chmod 777 xml_dumper.sh"

# Clean up the last dump
docker exec $APP_CONTAINER_ID bash -c "./xml_dumper_cleanup.sh"

# Execute XML dump generator script
docker exec $APP_CONTAINER_ID bash -c "./xml_dumper.sh"

# Copy the XML dump to our backup location
docker cp $APP_CONTAINER_ID:/var/www/html/dump.xml /mnt/$BACKUP_VOLUME/mediawiki_backup/$CURRENT_TIMESTAMP/xml_backup/


### END
