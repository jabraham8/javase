#!/bin/bash

function vcap_exists(){
  if [ "x" == "x${VCAP_SERVICES}" ] ; then
    # does not exist
    return 1
  else
    # exists
    return 0
  fi
}

function write_vcap() {

  echo "$date [INFO] Export VCAP_SERVICES=$vcap" >> $LOG_FILE
  export VCAP_SERVICES="$vcap"

}

function read_vcap_url() {

  vcap="{}"

  if [ "x" == "x${APP_NAME}" ] ; then
    echo "$date [WARN] Impossible to get the VCAP_SERVICES environment variable. APP_NAME env is not defined." >> $LOG_FILE
    echo "$date [WARN] Impossible to get the VCAP_SERVICES environment variable. APP_NAME env is not defined."
    return
  fi

  if [ "x" == "x${SERVICE_MANAGER_URL}" ] ; then
    echo "$date [WARN] Impossible to get the VCAP_SERVICES environment variable. SERVICE_MANAGER_URL env is not defined." >> $LOG_FILE
    echo "$date [WARN] Impossible to get the VCAP_SERVICES environment variable. SERVICE_MANAGER_URL env is not defined."
    return
  fi

  parameters="appId=${APP_NAME}"

  URL="${SERVICE_MANAGER_URL}?${parameters}"

  vcap=`curl -f -s -X GET $URL`
  rc=$?

  if [ $rc -ne 0 ]; then
    echo "$date [ERROR] Impossible to get the VCAP_SERVICES environment variable. Return code: $rc" >> $LOG_FILE
    echo "$date [ERROR] Impossible to get the VCAP_SERVICES environment variable. Return code: $rc"

    vcap="{}"
  fi

}


LOG_DIR=$HOME/logs/
mkdir -p $LOG_DIR
LOG_FILE=${LOG_DIR}service_manager_binder.log

date=`date`

# if VCAP_SERVICES is defined by user don't set it
if ! vcap_exists ; then

  read_vcap_url
  write_vcap

fi
