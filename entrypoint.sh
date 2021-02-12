#!/bin/bash

function ensure_variable_populated {
  VAR=$1
  if [ -z "${!VAR}" ]; then
    echo "Mandatory variable: ${VAR} not set, exiting"
    exit 1
  fi
}

function run_collection {
  echo "COLLECTION running"
  python cloudmapper.py configure add-account --config-file config.json --name ${ACCOUNT_NAME} --id ${ACCOUNT_ID}
  python cloudmapper.py collect --account ${ACCOUNT_NAME}
  python cloudmapper.py report --account ${ACCOUNT_NAME}
  python cloudmapper.py prepare --account ${ACCOUNT_NAME}
}

function webserver_mode {
  echo "WEBSERVER running"
  python cloudmapper.py webserver --public
}

function helptext {

  echo "USAGE: run with the following args"
  echo "--collect : collect logs and prepare report"
  echo "--webserver : start webserver on port 8000"
  echo "--help : show this text and quit"
  exit 0

}

ensure_variable_populated "ACCOUNT_NAME"
ensure_variable_populated "ACCOUNT_ID"
ensure_variable_populated "AWS_ACCESS_KEY_ID"
ensure_variable_populated "AWS_SECRET_ACCESS_KEY"

cd /opt/cloudmapper

COLLECTION=false
WEBSERVER=false

for arg in "$@"
do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ] ; then
        helptext
    elif [ "$arg" == "--webserver" ] ; then
      WEBSERVER=true
    elif [ "$arg" == "--collect" ] ; then
      COLLECTION=true
    fi

done

if [ "${COLLECTION}" == "false" ] && [ "${WEBSERVER}" == "false" ] ; then
  echo "No mode specified, dropping to bash"
  /bin/bash
else
  [ "${COLLECTION}" == "true" ] && run_collection
  [ "${WEBSERVER}" == "true" ] && webserver_mode
fi
