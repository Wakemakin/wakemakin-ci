#!/bin/bash
if [ -z "$PROJECT" ]; then
  echo "Project is undefined. Cannot continue"
  exit 1
fi
if [ "$PROJECT" = "unset" ]; then
  echo "Project hasn't been set. Cannot continue"
  exit 1
fi
WORKING="$WORKSPACE/$PROJECT"
TARGETDIR="/opt/faro/$PROJECT"
DEPLOYDIR="/var/deploys/$PROJECT"
VENV="$TARGETDIR/.venv"
cd $WORKING
if [ ! -d "$TARGETDIR" ]; then
  mkdir -p "$TARGETDIR"
fi
if [ -d "$VENV" ]; then
  rm -rf "$VENV"
fi
virtualenv --prompt="($PROJECT)" --distribute --no-site-packages "$VENV"
if [ $? -ne 0 ]; then
  echo "Error creating virtualenv"
  exit 1
fi
source "$VENV/bin/activate"
pip install -r pip-requirements.txt
if [ $? -ne 0 ]; then
  echo "Error pip install pip-requirements.txt"
  exit 1
fi
pip install -r test-requirements.txt
if [ $? -ne 0 ]; then
  echo "Error pip install test-requirements.txt"
  exit 1
fi
pip install tox
if [ ! -d "$DEPLOYDIR" ]; then
  mkdir -p "$DEPLOYDIR"
fi
deactivate
mv "$VENV" .venv
outfile=`fpm -f -n "$PROJECT" -s dir -t deb -v 0.1 --iteration $EXT_BUILD\
    --deb-compression bzip2 --inputs MANIFEST\
    -p /var/deploys/NAME/NAME_FULLVERSION_ARCH.TYPE\
    --vendor "Wakemakin Development House L.L.C"\
    -d python-dev -d python-virtualenv\
    -d libmysqlclient-dev\
    --description 'RESTful api for Project faro'\
    --url "https://github.com/Wakemakin/$PROJECT" --prefix "$TARGETDIR"`
parsed_file=`echo $outfile | sed 's/[{}:" ]//g' | sed 's/,/\n/g' | awk -F"=>" 'toupper($1) == "PATH" {print $2}'`
echo "Created deb: $parsed_file"
if [ $? -ne 0 ]; then
  echo "Error creating deb"
  exit 1
fi
if [ -e "$DEPLOYDIR/latest" ]; then
  rm "$DEPLOYDIR/latest"
fi
ln -s $parsed_file "$DEPLOYDIR/latest"
if [ -f "${HOME}/.gpg-agent-info" ]; then
  . "${HOME}/.gpg-agent-info"
  export GPG_AGENT_INFO
  export SSH_AUTH_SOCK
fi
freight-add $parsed_file apt/saucy apt/raring
if [ $? -ne 0 ]; then
  echo "Error putting deb into repo"
  exit 1
fi
freight-cache apt/saucy apt/raring
if [ $? -ne 0 ]; then
  echo "Error caching repo"
  exit 1
fi
rm -rf .venv
