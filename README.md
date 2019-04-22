# hadoop-cluster
Hadoop 3, Hbase, Spark and Hive <br />
Please download required packages before docker building:   <br />
* spark-2.4.1-bin-hadoop2.7.tgz
* hue-4.3.0.tgz  
* apache-hive-2.3.4-bin.tar.gz   
* hadoop-3.1.2.tar.gz     
* hbase-1.4.9-bin.tar.gz  


## Build image:<br />
docker build -t hadoop3hbase-spark-hive .  <br />

## Pull image from dockerhub
docker pull sdwangntu/hive-metastore-db   <br />
docker pull sdwangntu/sdwangntu/hive-metastore-db   <br />

## Launch cluster:  <br />
docker run --hostname=mysql --name mysql --network  my-attachable-network -d sdwangntu/hive-metastore-db
docker run --hostname=hadoop-master --name hadoop-master --network  my-attachable-network -d sdwangntu/hadoop3hbase-spark-hive  <br />
docker run --hostname=hadoop-worker --name hadoop-worker --network  my-attachable-network -d sdwangntu/hadoop3hbase-spark-hive  <br />
 

