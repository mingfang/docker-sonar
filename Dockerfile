FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y --no-install-recommends oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#MySQL
RUN apt-get install -y mysql-server && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

#Sonar
RUN wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.0.zip && \
    unzip sonar*.zip && \
    rm sonar*.zip && \
    mv sonar* sonar

#Init MySql
ADD mysql.ddl /
ADD preparedb.sh /
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < mysql.ddl && \
    mysqladmin shutdown
RUN sed -i -e "s|#sonar.jdbc.url=jdbc:mysql|sonar.jdbc.url=jdbc:mysql|" /sonar/conf/sonar.properties

#Add runit services
ADD sv /etc/service 
