#!/bin/bash

### CONFIGURE SOURCES

curl -fsSL https://www.apache.org/dist/cassandra/KEYS | apt-key add -
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
curl https://raw.githubusercontent.com/TheHive-Project/TheHive/master/PGP-PUBLIC-KEY | apt-key add -
echo 'deb https://deb.thehive-project.org release main' | tee -a /etc/apt/sources.list.d/thehive-project.list

apt update -y && apt upgrade -y

### INSTALL JAVA

apt-get install -y openjdk-8-jre-headless -y
echo JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" | tee -a /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

### INSTALL CASSANDRA

apt install cassandra -y
sleep 30
cqlsh -e "UPDATE system.local SET cluster_name = 'thp' where key='local';"
sleep 1
nodetool flush
cp ./cassandra.yaml /etc/cassandra/cassandra.yaml
systemctl restart cassandra
systemctl enable cassandra
sleep 30

### INSTALL ELASTICSEARCH

apt install elasticsearch -y
systemctl start elasticsearch
systemctl enable elasticsearch
sleep 30

### INSTALL THEHIVE

apt-get install thehive4 -y
mkdir /opt/thp/thehive/index
mkdir /opt/thp/thehive/files
chown thehive:thehive -R /opt/thp/thehive/index
chown thehive:thehive -R /opt/thp/thehive/files

cp ./application.conf /etc/thehive/application.conf

systemctl start thehive
systemctl enable thehive

sleep 60

### TEST PORTS
echo "Cassandra:"
ss -alnp | grep 7000
echo "ElasticSearch:"
ss -alnp | grep 9200
echo "The Hive:"
ss -alnp | grep 9000