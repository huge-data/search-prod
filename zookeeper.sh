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

BASE_DIR="~/zookeeper-cloud/"

usage() {
  echo >&2 "Usage: $PRG <command> [args]"
  echo 'Valid commands: install, start, status, restart, stop, deldata, delall'
  exit 1
}

install() {
    MYID=1;
    for i in `cat $@`;
    do 
        echo $i": install ...";
        # scp files
        scp -r zookeeper-cloud $i:~/;
        # create myid
        ssh $i "echo "$MYID" > "$BASE_DIR"zk_data/myid";
        MYID=$(($MYID+1));
    done;
}

start() {
    for i in `cat $@`;
    do 
        echo $i": start ...";
        ssh $i $BASE_DIR"zookeeper-3.4.5/bin/zkServer.sh start";
    done;
}

status() {
    for i in `cat $@`;
    do 
        echo $i": status ...";
        ssh $i $BASE_DIR"zookeeper-3.4.5/bin/zkServer.sh status";
    done;
}

restart() {
    for i in `cat $@`;
    do 
        echo $i": restart ...";
        ssh $i $BASE_DIR"zookeeper-3.4.5/bin/zkServer.sh restart";
    done;
}

stop() {
    for i in `cat $@`;
    do 
        echo $i": stop ...";
        ssh $i $BASE_DIR"zookeeper-3.4.5/bin/zkServer.sh stop";
    done;
}

deldata() {
    for i in `cat $@`;
    do 
        echo $i": deldata ...";
        ssh $i "rm -r "$BASE_DIR"zk_data/version-2;rm -r "$BASE_DIR"zk_logs/*;rm -r "$BASE_DIR"zookeeper.out";
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
        shift
        start $@
        ;;
    (status)
        shift
        status $@
        ;;
    (restart)
        shift
        restart $@
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
