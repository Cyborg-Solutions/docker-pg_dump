#!/bin/ash

set -e

# Definição das variáveis padrão
COMMAND=${1:-dump}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}  # Cron diário às 1h da manhã
PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
PGDB_LIST=${PGDB_LIST:-"postgres"}
PGHOST=${PGHOST:-db}
PGPORT=${PGPORT:-5432}
TZ=${TZ:-"America/Sao_Paulo"}  # Fuso horário de São Paulo

export TZ="/usr/share/zoneinfo/${TZ}"

if [[ "$COMMAND" == 'dump' ]]; then
    for PGDB in $PGDB_LIST; do
        export PGDB
        FILENAME="${PREFIX}_${PGDB}_$(date +"%Y%m%d_%H%M%S").sql.gz"
        exec /dump.sh > "$FILENAME"
    done
elif [[ "$COMMAND" == 'dump-cron' ]]; then
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    # Configuração do ambiente cron
    CRON_ENV="PREFIX='$PREFIX'\nPGUSER='$PGUSER'\nPGDB_LIST='$PGDB_LIST'\nPGHOST='$PGHOST'\nPGPORT='$PGPORT'"
    if [ -n "$PGPASSWORD" ]; then
        CRON_ENV="$CRON_ENV\nPGPASSWORD='$PGPASSWORD'"
    fi
    
    if [ ! -z "$DELETE_OLDER_THAN" ]; then
        CRON_ENV="$CRON_ENV\nDELETE_OLDER_THAN='$DELETE_OLDER_THAN'"
    fi
    
    # Adiciona a tarefa cron e inicia o cron
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1" | crontab -
    crontab -l
    cron
    tail -f "$LOGFIFO"
else
    echo "Comando desconhecido: $COMMAND"
    echo "Comandos disponíveis: dump, dump-cron"
    exit 1
fi