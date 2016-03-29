FROM centos:7
MAINTAINER Paradigma BOL  carrefour-bol@paradigmadigital.com

ADD application.jar /

ENV JAVA_VERSION 1.8.0
ENV GID 20000
# This hast to be the userId because is the one that runs openshift (Paradigma Openshift)
ENV UID 1000060000
ENV APP_HOME /opt/app 
ENV IMAGE_SCRIPTS_HOME /opt/paradigma
ENV CERTS_HOME /etc/pki/tls/certs
ENV FILEBEAT_CONF_DIR /etc/filebeat
ENV FILEBEAT_VERSION 1.1.2

RUN mkdir -p $APP_HOME && \
	mkdir $IMAGE_SCRIPTS_HOME && \
	mkdir -p $CERTS_HOME
	
RUN groupadd --gid $GID java && useradd --uid $UID -m -g java java && \
	yum -y install \
	   initscripts \
       java-$JAVA_VERSION-openjdk-devel \
       procps-ng \
       strace \
       wget && \
    yum clean all		
	
COPY Dockerfile $IMAGE_SCRIPTS_HOME/Dockerfile
COPY scripts $IMAGE_SCRIPTS_HOME
COPY certs $CERTS_HOME

RUN chown -R java:java $APP_HOME && \
    chown -R java:java $IMAGE_SCRIPTS_HOME && \	
	chown -R java:java $CERTS_HOME
	
RUN chmod -R +rwx $IMAGE_SCRIPTS_HOME && \
	chmod -R +rwx $APP_HOME && \ 
	chmod -R +rwx $CERTS_HOME
	
EXPOSE 8080

LABEL io.k8s.description="Java 8 runtime for Spring boot microservices" \
	  io.openshift.expose-services="8080:https" \
      io.openshift.tags="java8,microservices,spring-boot,filebeat"

ENV io.k8s.description="Java 8 runtime for Spring boot microservices" \
	io.openshift.expose-services="8080:https" \
    io.openshift.tags="java8,microservices,spring-boot,filebeat"

# Install filebeat to transfer logs
RUN curl -L -O https://download.elastic.co/beats/filebeat/filebeat-$FILEBEAT_VERSION-x86_64.rpm && \
	rpm -vi filebeat-$FILEBEAT_VERSION-x86_64.rpm

# Use our filebeat configuration
COPY conf/filebeat.yml $FILEBEAT_CONF_DIR/filebeat.yml

WORKDIR $IMAGE_SCRIPTS_HOME

USER java

CMD [ "./start.sh" ]

