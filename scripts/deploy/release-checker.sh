#!/bin/bash
PCOUNT=`ps aux | grep faro_api | grep gunicorn | wc -l`
RELEASE=`curl -s $2`
TIMEOUT=0
MAX_TIMEOUT=60
while [ $RELEASE -ne $1 ]; do
    sleep 1
    RELEASE=`curl -s $2`
    TIMEOUT=`expr $TIMEOUT + 1`
    if [ $TIMEOUT -gt $MAX_TIMEOUT ]; then
        echo 1
        exit 1
    fi
done
echo 0
exit 0
