# Docker image of pinpoint server
# VERSION 0.0.1
# Author: bolingcavalry

#基础镜像使用kinogmt/centos-ssh:6.7，这里面已经装好了ssh，密码是password
FROM kinogmt/centos-ssh:6.7

#作者
MAINTAINER BolingCavalry <zq2599@gmail.com>

#定义工作目录
ENV WORK_PATH /usr/local/work

#定义jdk1.8的文件夹
ENV JDK_PACKAGE_FILE jdk1.8.0_144

#定义jdk1.8的文件名
ENV JDK_RPM_FILE jdk-8u144-linux-x64.rpm

#定义hbase文件名
ENV HBASE_PACKAGE_NAME hbase-1.2.6

#定义collector文件夹名
ENV COLLECTOR_PACKAGE_NAME tomcat-collector

#定义web文件夹名
ENV WEB_PACKAGE_NAME tomcat-web

#定义pinpoint的hbase初始化数据脚本名称
ENV PINPOINT_HBASE_INIT_DATA_NAME hbase-create.hbase

#yum更新
#RUN yum -y update

#把分割过的jdk1.8安装文件复制到工作目录
COPY ./jdkrpm-* $WORK_PATH/

#用本地分割过的文件恢复原有的jdk1.8的安装文件
RUN cat $WORK_PATH/jdkrpm-* > $WORK_PATH/$JDK_RPM_FILE

#本地安装jdk1.8，如果不加后面的yum clean all，就会报错：Rpmdb checksum is invalid
RUN yum -y localinstall $WORK_PATH/$JDK_RPM_FILE; yum clean all

#把hbase文件夹复制到工作目录
COPY ./$HBASE_PACKAGE_NAME $WORK_PATH/hbase

#把collector文件夹复制到工作目录
COPY ./$COLLECTOR_PACKAGE_NAME $WORK_PATH/$COLLECTOR_PACKAGE_NAME

#把web文件夹复制到工作目录
COPY ./$WEB_PACKAGE_NAME $WORK_PATH/$WEB_PACKAGE_NAME

#把pinpoint的初始化数据文件复制到工作目录
COPY ./$PINPOINT_HBASE_INIT_DATA_NAME $WORK_PATH/

#删除jdk分割文件
RUN rm $WORK_PATH/jdkrpm-*

#删除jdk安装包文件
RUN rm $WORK_PATH/$JDK_RPM_FILE

#赋读权限
RUN chmod a+r $WORK_PATH/hbase/conf/hbase-env.sh

#赋读权限
#RUN chmod a+r $WORK_PATH/hbase/conf/hbase-site.xml

#配置hostname
RUN echo HOSTNAME=master>>/etc/sysconfig/network

#定义环境变量
ENV JAVA_HOME=/usr/java/$JDK_PACKAGE_FILE/
ENV HBASE_HOME=$WORK_PATH/hbase/
ENV PATH=$JAVA_HOME/bin:$HBASE_HOME/bin:$PATH

EXPOSE 60010
EXPOSE 18080
EXPOSE 28080