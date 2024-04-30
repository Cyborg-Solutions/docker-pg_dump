#!/bin/ash

set -e

echo "Tarefa iniciada: $(date)"

DATE=$(date +%Y%m%d_%H%M%S)

for PGDB in $PGDB_LIST; do
    FILE="/dump/${PREFIX}-${PGDB}-${DATE}.sql"
    pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -Fc -b -v -f "$FILE" -d "$PGDB"
    gzip "$FILE"
done

pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "/dump/${PREFIX}-roles-${DATE}.sql" --no-role-passwords -g
gzip "/dump/${PREFIX}-roles-${DATE}.sql"

if [ ! -z "$DELETE_OLDER_THAN" ]; then
    echo "Excluindo backups antigos com mais de $DELETE_OLDER_THAN minutos"
    find /dump/* -mmin "+$DELETE_OLDER_THAN" -exec rm {} \;
fi

echo "Tarefa concluída: $(date)"
