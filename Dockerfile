FROM ubuntu

RUN	echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list
RUN	echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive

#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

#Supervisord
RUN apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN apt-get install -y openssh-server && mkdir /var/run/sshd && echo 'root:root' |chpasswd

#Utilities
RUN apt-get install -y vim less ntp net-tools inetutils-ping curl git unzip

#Install Oracle Java 7
RUN apt-get install -y python-software-properties && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer

#Sonar
RUN wget http://dist.sonar.codehaus.org/sonar-3.7.2.zip && \
    unzip sonar-*.zip && \
    rm sonar-*.zip


