FROM ubuntu:16.04 as base

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/skel/.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US.UTF-8 && dpkg-reconfigure locales
ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD bash -c 'export > /etc/envvars && /usr/sbin/runsvdir-start'

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y --no-install-recommends oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Sonar
RUN wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.7.zip && \
    unzip sonar*.zip && \
    rm sonar*.zip && \
    mv sonar* sonar

RUN sed -i -e "s|#sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?|sonar.jdbc.url=jdbc:mysql://sonar-db:3306/sonar?useServerPrepStmts=true\&maxAllowedPacket=20000000\&|" /sonar/conf/sonar.properties
RUN sed -i -e "s|#sonar.jdbc.username=|sonar.jdbc.username=sonar|" /sonar/conf/sonar.properties
RUN sed -i -e "s|#sonar.jdbc.password=|sonar.jdbc.password=sonar|" /sonar/conf/sonar.properties

#Add runit services
ADD sv /etc/service 
