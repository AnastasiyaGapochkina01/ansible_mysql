#!/bin/bash

export $(cat .config | xargs)
BACKUP_DIR="${BACKUP_DIR}/mysql/${DB}"
DATE=$(date +%Y-%m-%d-%H)

# Create dir for backups
if [ ! -d "$BACKUP_DIR" ]; then
  echo "::=> Directory does not exist :: $BACKUP_DIR"
  mkdir -p $BACKUP_DIR
fi

# Create backup
/usr/bin/mysqldump --defaults-file=/etc/mysql/.root.cnf -uroot --lock-tables=false $DB $IGNOR | gzip -c > "$BACKUP_DIR/$DB-$DATE.sql.gz"

# Copy backups to s3
sudo s3cmd put $BACKUP_DIR/$DB-$DATE.sql.gz s3://anestesia/

# Remove old backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +$DAYS | xargs rm -f
