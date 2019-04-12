FROM centos:latest
MAINTAINER Pawan Gonnakuti <pawang@datacom.co.nz>
LABEL version="6.5", os="centos7(latest/updated)", java="serverjre:8 (oracle)", aemversion="6.5", aem-type="publish", aem-properties-folder="/opt/aem-config", aem-logs="/opt/aem/crx-quickstart/logs"

#A little cleanup as per centos documentation
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
#Container Size: 202MB

#updating the os using yum, and cleaning the yum cache
RUN yum -y update; yum clean all
#Container Size: 238MB

#aem default location /opt/aemdocker
WORKDIR /opt/aem/

#add java jre layer.
FROM  store/oracle/serverjre:8
ENV container "aem-6.5-quickstart,aem-publish,centos,java8"
#Container Size: 280MB

#copy AEM_6.5 and license files.
COPY *.jar /opt/aem/
#Container Size: 822MB

RUN nohup java -jar /opt/aem/AEM_6.5_Quickstart.jar -unpack -v
#Container Size: 1.37GB 

#NOTE: make sure to copy admin.password.file and license.properties files to the /opt/aem-config folder.
VOLUME ["/opt/aem-config/"]
VOLUME ["/opt/aem/crx-quickstart/logs"]
EXPOSE 8080
#Command below is executed at runtime, instead of build
CMD /bin/bash -c "cp -v /opt/aem-config/* /opt/aem; cd /opt/aem/ ;  java -Xms1024m -Xmx2048m -jar ./AEM_6.5_Quickstart.jar -v -r publish,crx3 -p 4040 -Dadmin.password.file=./admin.password.file -nointeractive -nobrowser"
