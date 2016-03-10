#!/bin/bash

echo "========================================="
echo "Starting application"
echo "========================================="
env | sort

if [ -n "$TZ" ]
then
   export TZ
else
   export TZ="Europe/Madrid"
fi

LOG_DIR=$APP_HOME/logs/
mkdir -p $LOG_DIR
LOG_FILE=${LOG_DIR}service_manager_binder.log

date=`date`


#### I have to validate if ARTIFACT_URL is available

if [ -n "$ARTIFACT_URL" ]
then
  file=`basename "$ARTIFACT_URL"`
  wget -q --no-check-certificate --connect-timeout=5 --read-timeout=10 --tries=2 -O "/tmp/$file" "$ARTIFACT_URL"

  #### I have to unpackage the file to $APP_HOME

  if [ $? -eq 0 ]
  then
    if [[ $ARTIFACT_URL = *.jar* ]]
    then
       cp /tmp/$file "$APP_HOME"
    fi
	if [[ $ARTIFACT_URL = *.war* ]]
    then
       cp /tmp/$file "$APP_HOME"
    fi
  else
    echo "ERROR: while Downloading file from $ARTIFACT_URL"
    return 1
  fi
fi

#### If JAR_PATH is empty I have to find a JAR in $APP_HOME

if [ -z "$JAR_PATH" ]
then
   JAR_PATH=`find $APP_HOME -name "*.jar" -o -name "*.war" | head -1`
fi

if [ -z "$JAR_PATH" ]
then
   JAR_PATH="/application.jar"
fi

exec java $JAVA_HEAP $JAVA_OPTS_EXT -jar "$JAR_PATH" $JAVA_PARAMETERS