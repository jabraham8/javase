#!/bin/bash

echo "========================================="
echo "Starting application"
echo "========================================="
env | sort


##We are going to precalculate default java heap configuration:

#### When a container has its memory limited, it is reflected in /sys/fs/cgroup/memory/memory.limit_in_bytes
##AVAIL_MEM=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
##let AVAIL_MEM_MB=$AVAIL_MEM/1024/1024
##mem_literal="$AVAIL_MEM_MB"m

#### default Java Heap configuration
## Tool extracted from https://github.com/cloudfoundry/java-buildpack-memory-calculator
# ./java-buildpack-memory-calculator -memoryWeights=heap:70,metaspace:15,native:10 -totMemory=512m
##JAVA_HEAP=$(/opt/produban/bin/java-buildpack-memory-calculator -memoryWeights=heap:70,metaspace:15,native:10 -totMemory=$mem_literal)


#### I have to validate if ARTIFACT_URL is available

if [ -n "$ARTIFACT_URL" ]
then
  file=`basename "$ARTIFACT_URL"`
  wget -q --no-check-certificate --connect-timeout=5 --read-timeout=10 --tries=2 -O "/tmp/$file" "$ARTIFACT_URL"

  #### I have to unpackage the file to $APP_HOME

  if [ $? -eq 0 ]
  then

    if [[ $ARTIFACT_URL = *.tgz* ]]
    then
       tar -xzvf /tmp/$file -C "$APP_HOME"
    fi
    if [[ $ARTIFACT_URL = *.zip* ]]
    then
       unzip  /tmp/$file  -d "$APP_HOME"
    fi
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

#### if you want to add extra JVM options,, you have to use the env variable JAVA_EXT_OPTS

###echo java $JAVA_HEAP $JAVA_OPTS_EXT -jar "$JAR_PATH" $JAVA_PARAMETERS
exec java $JAVA_HEAP $JAVA_OPTS_EXT -jar "$JAR_PATH" $JAVA_PARAMETERS