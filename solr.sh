#!/bin/bash

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

PROJECT_DIR=`cd "$PRGDIR/.." >/dev/null; pwd`
#echo PROJECT_DIR=$PROJECT_DIR

BASE_DIR="~/solr-cloud/"
SOLR_VERSION="4.8.0"

usage() {
  echo >&2 "Usage: $PRG <command> [args]"
  echo 'Valid commands: install, start, status, stop, deldata, delall'
  exit 1
}

install() {
    for i in `cat $@`;
    do 
        echo $i": install ...";
        scp -r solr-cloud $i:~/;
    done;
}

start() {
    MASTER=`cat master`;
    echo $MASTER": start master ...";
    ssh $MASTER "cd solr-cloud/solr-"$SOLR_VERSION";java -Xms8192M -Xmx10240M -Dbootstrap_confdir=./solr/sentiment/conf -Dcollection.configName=zxsoft -DnumShards=5 -DzkHost=192.168.43.201:2181,192.168.43.100:2181,192.168.43.101:2181,192.168.43.111:2181,192.168.43.121:2181 -jar start.jar &" &
    echo "sleeping ..."

    for ((i=60;i>0;i--))
    do 
        echo "After "$i" seconds, it will start slaves ...";sleep 1;
    done

    for i in `cat slaves`;
    do
        echo $i": start slave ...";
        ssh $i "cd solr-cloud/solr-"$SOLR_VERSION";java -Xms8192M -Xmx10240M -DzkHost=192.168.43.201:2181,192.168.43.100:2181,192.168.43.101:2181,192.168.43.111:2181,192.168.43.121:2181 -jar start.jar &" &
    done;
}

status() {
    for i in `cat $@`;
    do
        echo $i": status ...";
        ssh $i "ps aux | grep start.jar | grep -v grep";
    done;
}

stop() {
    for i in `cat $@`;
    do 
        echo $i": stop ...";
        PID=$(ssh $i "ps aux | grep start.jar | grep -v grep" | awk '{print $2}');
        ssh $i "kill -9 "$PID;
    done;
}

deldata() {
    for i in `cat $@`;
    do 
        echo $i": deldata ...";
        ssh $i "rm -r "$BASE_DIR"solr_data;rm -r "$BASE_DIR"solr_ulogs;rm -r "$BASE_DIR"solr_request_logs/*;rm -r "$BASE_DIR"solr_logs;rm -r "$BASE_DIR"solr_webapp";
    done;
}

delall() {
    for i in `cat $@`;
    do 
        echo $i": delall ...";
        ssh $i "rm -r "$BASE_DIR;
    done;
}

case $1 in
    (install)
        shift
        install $@
        ;;
    (start)
        start
        ;;
    (status)
        shift
        status $@
        ;;
    (stop)
        shift
        stop $@
        ;;
    (deldata)
        shift
        deldata $@
        ;;
    (delall)
        shift
        delall $@
        ;;
    (*)
        echo >&2 "$PRG: error: unknown command '$1'"
        usage
        ;;
esac
