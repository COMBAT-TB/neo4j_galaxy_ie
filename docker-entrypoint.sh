#!/bin/bash -eu

DB_PATH=/data/neo4jdb
export DB_PATH
NEO4J_dbms__directories__data=/data/neo4jdb

if [ "$1" == "neo4j" ]; then
    if [ "${USER_UID:=none}" = "none" -o "${USER_GID:=none}" = "none" ] ; then
        echo "You need to set the USER_UID and USER_GID environment variables to use this container." >&2
        exit 1
    fi

    NEO4J_GROUP=$(getent group $USER_GID | cut -d: -f1)
    if [ -z "$NEO4J_GROUP" ] ; then
        NEO4J_GROUP=neo4j
        groupadd -g $USER_GID $NEO4J_GROUP
        echo "Added $USER_GID to $NEO4J_GROUP"
    fi
    NEO4J_USER=$(getent passwd $USER_UID | cut -d: -f1)
    if [ -z "$NEO4J_USER" ] ; then
        NEO4J_USER=neo4j
        useradd -u $USER_UID -g $NEO4J_GROUP $NEO4J_USER
    fi
    chown -R $USER_UID:$USER_GID /opt /data
    EXISTING_UID=$(stat -c '%u' /data)
    EXISTING_GID=$(stat -c '%g' /data)
    echo "/opt /data $EXISTING_UID $EXISTING_GID"
    if [ $(stat -c '%u' /data) -ne $USER_UID -o $(stat -c '%g' /data) -ne $USER_GID ] ; then
        EXISTING_UID=$(stat -c '%u' /data)
        EXISTING_GID=$(stat -c '%g' /data)
        echo "The /data volume must be owned by user ID $USER_UID and group ID $USER_GID, instead it is owned by ${EXISTING_UID}: ${EXISTING_GID}" >&2
        exit 1
    fi
    if [ ! -d $DB_PATH ] ; then
        gosu $USER_UID:$USER_GID cp -r /opt/neo4j/data $DB_PATH
        echo "Initialising new database in $DB_PATH"
        # echo "There is no database in $DB_PATH, will exit." >&2
        # exit 1
    fi

    # set some settings in the neo4j install dir
    /set_neo4j_settings.sh

    rm -rf /opt/neo4j/data
    ln -s $DB_PATH /opt/neo4j/data
    # Launch traffic monitor which will automatically kill the container if
    # traffic stops - it waits 60 seconds before checking for an open
    # connection so this is safe
    /monitor_traffic.sh &

    gosu $USER_UID:$USER_GID /run_neo4j.sh
elif [ "$1" == "dump-config" ]; then
    if [ -d /conf ]; then
        cp --recursive conf/* /conf
    else
        echo "You must provide a /conf volume"
        exit 1
    fi
else
    exec "$@"
fi
