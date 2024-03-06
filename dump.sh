#!/bin/ash

set -e

echo "Job started: $(date)"

DATE=$(date +%Y%m%d_%H%M%S)
FILE="/dump/$PREFIX-$DATE.sql"


pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -Fc -b -v -f "$FILE" -d "$PGDB" 
gzip "$FILE"

pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f /dump/${PREFIX}-roles-${DATE}.sql --no-role-passwords -g	
gzip "/dump/${PREFIX}-roles-${DATE}.sql"
if [ ! -z "$DELETE_OLDER_THAN" ]; then
	echo "Deleting old backups: $DELETE_OLDER_THAN"
	find /dump/* -mmin "+$DELETE_OLDER_THAN" -exec rm {} \;
fi



echo "Job finished: $(date)"
