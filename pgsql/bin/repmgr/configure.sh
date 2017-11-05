#!/usr/bin/env bash
set -e
REPLICATION_PASSWORD=$(get_secret REPLICATION_PASSWORD)

echo ">>> Setting up repmgr..."
REPMGR_CONFIG_FILE=/etc/repmgr.conf
cp -f /var/cluster_configs/repmgr.conf $REPMGR_CONFIG_FILE

if [ -z "$CLUSTER_NODE_NETWORK_NAME" ]; then
    export CLUSTER_NODE_NETWORK_NAME="`hostname`"
fi

#TODO: data_directory env?
echo ">>> Setting up repmgr config file '$REPMGR_CONFIG_FILE'..."
echo "
use_replication_slots=$USE_REPLICATION_SLOTS
pg_bindir=/usr/lib/postgresql/$PG_MAJOR/bin
node_id=$NODE_ID
node_name=$NODE_NAME
conninfo='user=$REPLICATION_USER password=$REPLICATION_PASSWORD host=$CLUSTER_NODE_NETWORK_NAME dbname=$REPLICATION_DB port=$REPLICATION_PRIMARY_PORT connect_timeout=$CONNECT_TIMEOUT'
failover=automatic
promote_command='PGPASSWORD=$REPLICATION_PASSWORD repmgr standby promote --log-level DEBUG --verbose'
follow_command='PGPASSWORD=$REPLICATION_PASSWORD repmgr standby follow -W --log-level DEBUG --verbose'
reconnect_attempts=$RECONNECT_ATTEMPTS
reconnect_interval=$RECONNECT_INTERVAL
log_level=$LOG_LEVEL
priority=$NODE_PRIORITY
data_directory=/var/lib/postgresql/data
" >> $REPMGR_CONFIG_FILE

chown postgres $REPMGR_CONFIG_FILE
