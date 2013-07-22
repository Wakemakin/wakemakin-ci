#!/bin/bash
if [[ $UID -ne 0 ]]; then
    echo "$0 must be run as root"
    exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFEST_DIR="/etc/puppet/manifests"
MODULE_DIR="/etc/puppet/modules"
if [ -d "$MANIFEST_DIR" ]; then
    rm -rf $MANIFEST_DIR
fi
if [ -d "$MODULE_DIR" ]; then
    rm -rf $MODULE_DIR
fi
cp -r $DIR/manifests $MANIFEST_DIR
cp -r $DIR/modules $MODULE_DIR
