#!/bin/bash

: ${HADOOP_PREFIX:=/opt/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
export HBASE_HOME=/opt/hbase
export HIVE_HOME=/opt/hive

#rm /tmp/*.pid
export HADOOP_HOME=/opt/hadoop
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH

service ssh start
if [ "$HOSTNAME" = "hadoop-master" ] || [ "$1" = "all" ]
then
  $HADOOP_PREFIX/bin/hdfs namenode -format
  $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/hive/warehouse
  $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w /user/hive/warehouse
  $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w /tmp
  $HADOOP_PREFIX/bin/hdfs --daemon start namenode
  $HADOOP_PREFIX/bin/hdfs --daemon start datanode
  $HADOOP_PREFIX/bin/yarn --daemon start resourcemanager 
  $HADOOP_PREFIX/bin/yarn --daemon start nodemanager 
  $HADOOP_PREFIX/bin/mapred --daemon start historyserver
  $HBASE_HOME/bin/hbase-daemon.sh start zookeeper
  $HBASE_HOME/bin/hbase-daemon.sh start master
  $HBASE_HOME/bin/hbase-daemon.sh start thrift
  $HBASE_HOME/bin/hbase-daemons.sh start regionserver
# run the following initSchema at the first time start of the hadoop-master
  $HIVE_HOME/bin/schematool -initSchema -dbType mysql
  hive --service metastore &
  while true; do sleep 1000; done
elif [[ $HOSTNAME =~ .*hadoop-dev.* ]] # this is a hadoop dev container - for dev and submit job
then
  while true; do sleep 1000; done
else  # hadoop-worker container
  $HADOOP_PREFIX/bin/hdfs --daemon start datanode
  $HADOOP_PREFIX/bin/yarn --daemon start nodemanager 
  $HBASE_HOME/bin/hbase-daemons.sh start regionserver
#  $HBASE_HOME/bin/hbase-daemons.sh start master-backup
  while true; do sleep 1000; done
fi
#****** check node list
#yarn node -list
#hdfs dfsadmin -report
#****** test parameter 1000 -> 1000000
#yarn jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.2.jar pi 16 1000
