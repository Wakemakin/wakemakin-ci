#!/bin/bash
if [ -d ".venv" ]; then
  rm -rf .venv
fi
virtualenv --prompt='(faro-api)' --distribute --no-site-packages .venv
source .venv/bin/activate
pip install -r pip-requirements.txt
pip install -r test-requirements.txt
pip install tox
fpm -f -n faro-api -s dir -t deb -v 0.1 --iteration $BUILD_NUMBER\
    --deb-compression bzip2 --inputs MANIFEST\
    -p /var/deploys/NAME_FULLVERSION_ARCH.TYPE\
    --vendor "Wakemakin Development House L.L.C"\
    -d python-dev -d python-virtualenv\
    --url "https://github.com/Wakemakin/faro-api" --prefix /opt/faro/faro-api
if [ $? -ne 0 ]; then
  echo "Error creating deb"
  exit 1
fi
