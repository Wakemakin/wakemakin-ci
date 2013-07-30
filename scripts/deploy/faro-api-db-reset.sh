#!/bin/bash
DB='faro_api'
echo "Resetting the database: $DB"
echo "Stopping service"
supervisorctl stop faro_api
echo "Waiting for children to die"
sleep 30
echo "Dropping current DB and creating new one"
mysql -u root --password=password -e "drop database $DB; create database $DB;"
echo "Syncing database"
STATUS=`/opt/faro/faro-api/scripts/service-database-sync.sh`
echo "Sync returned: $STATUS"
echo "Restarting service"
supervisorctl start faro_api
