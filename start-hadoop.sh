#!/bin/bash

: ${HADOOP_PREFIX:=/opt/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
HBASE_HOME=/opt/hbase

#rm /tmp/*.pid
#export HADOOP_HOME=/opt/hadoop
#export HADOOP_COMMON_HOME=$HADOOP_HOME
#export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
#export HADOOP_HDFS_HOME=$HADOOP_HOME
#export HADOOP_MAPRED_HOME=$HADOOP_HOME
#export HADOOP_YARN_HOME=$HADOOP_HOME

#service ssh start
if [ "$HOSTNAME" = "hadoop-master" ] || [ "$1" = "all" ]
then
  $HADOOP_PREFIX/bin/hdfs namenode -format
  $HADOOP_PREFIX/bin/hdfs --daemon start namenode
  $HADOOP_PREFIX/bin/hdfs --daemon start datanode
  $HADOOP_PREFIX/bin/yarn --daemon start resourcemanager 
  $HADOOP_PREFIX/bin/yarn --daemon start nodemanager 
  $HADOOP_PREFIX/bin/mapred --daemon start historyserver
  $HBASE_HOME/bin/hbase master start
  $HBASE_HOME/bin/hbase regionserver start
else
  $HADOOP_PREFIX/bin/hdfs --daemon start datanode
  $HADOOP_PREFIX/bin/yarn --daemon start nodemanager 
  $HBASE_HOME/bin/hbase regionserver start
fi
while true; do sleep 1000; done
# test parameter 1000 -> 1000000
# yarn jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.2.jar pi 16 1000
