#!/bin/sh

set -ex
cd `dirname $0`

ISUCON_DB_HOST=${ISUCON_DB_HOST:-127.0.0.1}
ISUCON_DB_PORT=${ISUCON_DB_PORT:-3306}
ISUCON_DB_USER=${ISUCON_DB_USER:-isucon}
ISUCON_DB_PASSWORD=${ISUCON_DB_PASSWORD:-isucon}
ISUCON_DB_NAME=${ISUCON_DB_NAME:-isuports}

# admin テーブルを初期化
cat admin/01_create_mysql_database.sql admin/10_schema.sql admin/90_data.sql  mysql -u"$ISUCON_DB_USER" \
	-p"$ISUCON_DB_PASSWORD" \
	--host "$ISUCON_DB_HOST" \
	--port "$ISUCON_DB_PORT" \
	"$ISUCON_DB_NAME"
