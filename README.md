# hadoop-cluster
Hadoop 3, Hbase, Spark and Hive <br />
Please download required packages before docker building:   <br />
* hadoop-3.1.2.tar.gz  
* hbase-1.4.9-bin.tar.gz  
* spark-2.4.1-bin-hadoop2.7.tgz
* hue-4.3.0.tgz  
* apache-hive-2.3.4-bin.tar.gz  


## Build image:
* docker build -t hadoop3hbase-spark-hive .     

Note the hive-metastore-db image can be built at the directory Dockerfile-mysql, where mysql is used as the hive metastore DB.

## Pull image from dockerhub
* docker pull sdwangntu/hive-metastore-db   <br />
* docker pull sdwangntu/hadoop3hbase-spark-hive   <br />

## Create an attachable overlay network called for example "my-attachable-network"
* docker network create -d overlay --attachable my-attachable-network

## Launch cluster: (note the "hadoop-master" hostname is required as it is, the "hadoop-worker" hostname can be renamed to others)
* docker run --hostname=mysql --name mysql --network  my-attachable-network -d sdwangntu/hive-metastore-db  
* docker run --hostname=hadoop-master --name hadoop-master --network  my-attachable-network -d sdwangntu/hadoop3hbase-spark-hive    
* docker run --hostname=hadoop-worker --name hadoop-worker --network  my-attachable-network -d sdwangntu/hadoop3hbase-spark-hive   

Note the container exection order. And also check the startup routine "start-hadoop.sh" to see the roles played by each container.
 
## Launch a development container (this is a hadoop development container and is used for development and job submission) the "hadoop-dev" hostname  is required as it is
* docker run --hostname=hadoop-dev --name hadoop-dev -v $(pwd):/home --network  my-attachable-network -d sdwangntu/hadoop3hbase-spark-hive   

Note that bind current working directory, $(pwd), as a persistent work space to keep your developing projects.  

## Check the cluster status in the development container "hadoop-dev"
* hdfs dfsadmin -report

## Check the cluster node list in the development container "hadoop-dev"
* yarn node -list

## Test a mapreduce program such as pi in the development container "hadoop-dev" -- test parameter 10000 -> 1000000
* yarn jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.2.jar pi 4 10000
