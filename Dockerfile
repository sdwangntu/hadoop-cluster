FROM ubuntu:18.04

ENV HADOOP_HOME /opt/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update
RUN apt-get install -y --reinstall build-essential
RUN apt-get install -y ssh 
RUN apt-get install -y rsync 
RUN apt-get install -y vim 
RUN apt-get install -y net-tools
RUN apt-get install -y openjdk-8-jdk 
RUN apt-get install -y python2.7-dev 
RUN apt-get install -y libxml2-dev 
RUN apt-get install -y libkrb5-dev 
RUN apt-get install -y libffi-dev 
RUN apt-get install -y libssl-dev 
RUN apt-get install -y libldap2-dev 
RUN apt-get install -y python-lxml 
RUN apt-get install -y libxslt1-dev 
RUN apt-get install -y libgmp3-dev 
RUN apt-get install -y libsasl2-dev 
RUN apt-get install -y libsqlite3-dev  
RUN apt-get install -y libmysqlclient-dev

RUN \
    if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python2.7 /usr/bin/python; fi

# If you have already downloaded the tgz, add this line OR comment it AND ...
ADD hadoop-3.1.2.tar.gz /

# ... uncomment the 2 first lines
RUN \
#    wget http://apache.crihan.fr/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz && \
#    tar -xzf hadoop-3.1.2.tar.gz && \
    mv hadoop-3.1.2 $HADOOP_HOME && \
    for user in hadoop hdfs yarn mapred hue; do \
         useradd -U -M -d /opt/hadoop/ --shell /bin/bash ${user}; \
    done && \
    for user in root hdfs yarn mapred hue; do \
         usermod -G hadoop ${user}; \
    done && \
    echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
#    echo "export HDFS_DATANODE_SECURE_USER=hdfs" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh 

RUN chmod +x  $HADOOP_HOME/etc/hadoop/hadoop-env.sh
####################################################################################
# HUE

# https://www.dropbox.com/s/auwpqygqgdvu1wj/hue-4.1.0.tgz
ADD hue-4.3.0.tgz /


##
RUN mv -f /hue-4.3.0 /opt/hue
WORKDIR /opt/hue
RUN make apps

RUN chown -R hue:hue /opt/hue

WORKDIR /


####################################################################################

RUN \
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

ADD *xml $HADOOP_HOME/etc/hadoop/

ADD ssh_config /root/.ssh/config

ADD hue.ini /opt/hue/desktop/conf

#ADD workers  $HADOOP_HOME/etc/hadoop/workers
EXPOSE 8088 9870 9864 19888 8042 8888
#****** HBASE installation
ADD hbase-1.4.9-bin.tar.gz /
ENV HBASE_HOME /opt/hbase

RUN \
    mv hbase-1.4.9 $HBASE_HOME && \
    echo "export JAVA_HOME=$JAVA_HOME" >> $HBASE_HOME/conf/hbase-env.sh 
#    echo "PATH=$PATH:$HADOOP_HOME/bin:$HBASE_HOME/bin" >> ~/.bashrc

ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
# Master info port
EXPOSE 2181 16000 16010
#******
#***spark***
ADD spark-2.4.1-bin-hadoop2.7.tgz /
ENV SPARK_HOME /opt/spark

RUN mv spark-2.4.1-bin-hadoop2.7 $SPARK_HOME

ADD spark-env.sh $SPARK_HOME/conf/spark-env.sh
ADD spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
RUN chmod +x $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    chmod +x $SPARK_HOME/conf/spark-env.sh && \
    chmod +x  $HBASE_HOME/conf/hbase-env.sh
# *** hive ***
ADD apache-hive-2.3.4-bin.tar.gz / 
ENV HIVE_HOME /opt/hive
RUN mv apache-hive-2.3.4-bin $HIVE_HOME
ADD hive-site.xml  $HIVE_HOME/conf
ADD hive-env.sh $HIVE_HOME/conf
RUN chmod +x  $HIVE_HOME/conf/hive-env.sh
RUN apt-get install libmysql-java && \
    ln -s /usr/share/java/mysql-connector-java.jar /opt/hive/lib/libmysql-java.jar
# *** for scala applications dev ***
#RUN apt-get remove scala-library scala
#RUN wget www.scala-lang.org/files/archive/scala-2.11.12.deb
ADD scala-2.11.12.deb /
RUN dpkg -i scala-2.11.12.deb
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get update && \ 
    apt-get install -y sbt && \
    apt-get install -y netcat
# *** set PATH in .bashrc for all installed packages ***
ADD start-hadoop.sh start-hadoop.sh
RUN echo "PATH=$PATH:$HADOOP_HOME/bin:$HBASE_HOME/bin:$SPARK_HOME/bin:$HIVE_HOME/bin" >> ~/.bashrc && \
    echo "export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH" >> ~/.bashrc 
ENTRYPOINT ["bash","/start-hadoop.sh"]
