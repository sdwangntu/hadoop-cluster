# hadoop-cluster
Hadoop 3 and Hbase <br />
Please download required packages: hadoop-3.1.2.tar.gz  hbase-1.4.9-bin.tar.gz   hue-4.3.0.tgz <br />

Build image:
docker build -t hadoop3hbase .

Launch cluster:
docker run --hostname=hadoop-master -p 8088:8088 -p 9870:9870 -p 9864:9864 -p 19888:19888   -p 8042:8042 -p 8888:8888 --name hadoop-master --network  my-attachable-network -d hadoop3hbase
docker run --hostname=hadoop-worker --name hadoop-worker --network  my-attachable-network -d hadoop3hbase

