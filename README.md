# hadoop-cluster
Hadoop 3, Hbase, Spark and Hive <br />
Please download required packages before docker building:   <br />
* hadoop-3.1.2.tar.gz  
* hbase-1.4.9-bin.tar.gz  
* spark-2.4.1-bin-hadoop2.7.tgz
* hue-4.3.0.tgz  
* apache-hive-2.3.4-bin.tar.gz  


## Build image:
docker build -t hadoop3hbase-spark-hive .  <br />
Note the hive-metastore-db image can be built at the directory Dockerfile-mysql, where mysql is used as the hive metastore DB.

## Pull image from dockerhub
docker pull sdwangntu/hive-metastore-db   <br />
docker pull sdwangntu/hadoop3hbase-spark-hive   <br />

## Launch cluster: 
* docker run --hostname=mysql --name mysql --network  my-attachable-network -d sdwangntu/hive-metastore-db
* docker run --hostname=hadoop-master --name hadoop-master --network  my-attachable-network -d sdwangntu/hadoop3hbase-spark-hive  
* docker run --hostname=hadoop-worker --name hadoop-worker --network  my-attachable-network -d sdwangntu/hadoop3hbase-spark-hive 
Note the container exection order.
 
## Launch a development container
*  docker run -d -v `pwd`:/work --hostname=hadoop-dev --name hadoop-dev --network  my-attachable-network  hadoop3hbase-spark-hive
Note that bind current working directory (`pwd`) as a persistent work space to keep your developing projects.
