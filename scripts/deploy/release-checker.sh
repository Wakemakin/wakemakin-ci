#!/bin/bash
echo "Checking for release $1 at $2"
PCOUNT=`ps aux | grep faro_api | grep gunicorn | wc -l`
RELEASE=`curl -s $2`
TIMEOUT=0
MAX_TIMEOUT=35
while [ $RELEASE -ne $1 ]; do
    sleep 1
    RELEASE=`curl -s $2`
    TIMEOUT=`expr $TIMEOUT + 1`
    if [ $TIMEOUT -gt $MAX_TIMEOUT ]; then
        echo "Timeout reached waiting for release to update."
        exit 1
    fi
done
