# mediawiki-mariadb-docker-maintenance-scripts
This is my collection of shell scripts (backup &amp; restore, etc.) for Mediawiki Docker installation with MariaDB (also dockerized).

## Prerequisites
**The scripts currently assume that your mediawiki container is named mediawiki, and your MariaDB database container is named mariadb.**

**Additionally, currently the scripts assume that you have your backup location at /mnt/** - you should specify your specific backup volume directory in the scripts 
via the BACKUP_VOLUME variable in each script.

## How to use

### backup.sh
**Note: backup.sh backs up the database, XML dump and images. For all other assets the backup should be done manually. If the logo is in png format and is set to be 
in /resources/assets/, save it - restore.sh will restore it as well.
1. Ensure that you have a mounted volume (or some device or a folder) in the /mnt/ directory.
2. Change the BACKUP_VOLUME variable in each script to the name of that volume - for example, if your volume is my_volume, BACKUP_VOLUME should be set like this:
   
   ```BACKUP_VOLUME=my_volume``` 
   
   The final path for backup storage will be /mnt/my_volume/mediawiki_backup/ where the backups will be in folders, named according to the backup timestamp.
3. Run backup.sh - you now should see a new folder with the backup at /mnt/$BACKUP_VOLUME/mediawiki_backup/

### restore.sh
**WARNING - THIS SCRIPT DESTROYS THE OLD DATABASE**. If your database is corrupted but not completely lost I suggest backing up the data.
1. Place the xml_backup and db_backup folders, as well as your LocalSettings.php and your logo (but only if the logo is in png format and is set to be 
in /resources/assets/) at the directory named "backup", **which is a subdirectory of the directory from which you'll run restore.sh**
   Example: You will run restore.sh from ./test
   What to do: Create folder ./test/backup and place xmd_dump, db_dump, images folder, LocalSettings.php and (optionally) your logo there.
2. Start the mariadb and mediawiki containers
3. Run restore.sh

When it's done, you should be able to log in successfully using your credentials.

