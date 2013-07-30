#!/bin/bash
DB='faro_api'
echo "Resetting the database: $DB"
echo "Stopping service"
supervisorctl stop faro_api
echo "Waiting for children to die"
PCOUNT=`ps aux | grep faro_api | grep gunicorn | wc -l`
TIMEOUT=0
MAX_TIMEOUT=35
while [ $PCOUNT -ne 0 ]; do
    sleep 1
    PCOUNT=`ps aux | grep faro_api | grep gunicorn | wc -l`
    TIMEOUT=`expr $TIMEOUT + 1`
    if [ $TIMEOUT -gt $MAX_TIMEOUT ]; then
        echo "Timeout reached waiting for children to die."
        exit 1
    fi
done
echo "Dropping current DB and creating new one"
mysql -u root --password=password -e "drop database $DB; create database $DB;"
echo "Syncing database"
cd /opt/faro/faro-api
source .venv/bin/activate
STATUS=`/opt/faro/faro-api/scripts/service-database-sync.sh`
echo "Sync returned: $STATUS"
echo "Restarting service"
deactivate
supervisorctl start faro_api
