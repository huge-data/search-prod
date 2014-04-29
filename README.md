
一、ZookeeperCloud

1、安装

./zookeeper.sh install ips

2、启动

./zookeeper.sh start ips

3、查看状态

./zookeeper.sh status ips

4、重启

./zookeeper.sh restart ips

5、停止

./zookeeper.sh stop ips

6、删除索引以及日志文件

./zookeeper.sh deldata ips

7、删除全部文件

./zookeeper.sh delall ips


二、SolrCloud

1、安装

./solr.sh install ips

2、启动

1）显示日志信息
./solr.sh start

2）不显示日志信息
./solr.sh start &> /dev/null

3、查看状态

./solr.sh status ips

4、停止

./solr.sh stop ips

5、删除索引以及日志文件

./solr.sh deldata ips

6、删除全部文件

./solr.sh delall ips


