FROM centos:7
MAINTAINER Paradigma BOL  carrefour-bol@paradigmadigital.com

ADD application.jar /

ENV JAVA_VERSION 1.8.0
ENV GID 20000
ENV UID 20000
ENV APP_HOME /opt/app 
ENV IMAGE_SCRIPTS_HOME /opt/paradigma

RUN mkdir -p $APP_HOME && \
	mkdir $IMAGE_SCRIPTS_HOME
	
RUN groupadd --gid $GID java && useradd --uid $UID -m -g java java && \
	yum -y install \
       java-$JAVA_VERSION-openjdk-devel \
       procps-ng \
       strace \
       wget && \
    yum clean all	
	
COPY Dockerfile $IMAGE_SCRIPTS_HOME/Dockerfile
COPY scripts $IMAGE_SCRIPTS_HOME 

RUN chown -R java:java $APP_HOME && \
    chown -R java:java $IMAGE_SCRIPTS_HOME	
	
RUN chmod -R +rwx $IMAGE_SCRIPTS_HOME && \
	chmod -R +rwx $APP_HOME
	
EXPOSE 8080

LABEL io.k8s.description="Java 8 runtime for Spring boot microservices" \
	  io.openshift.expose-services="8080:https" \
      io.openshift.tags="java8,microservices,spring-boot"

ENV io.k8s.description="Java 8 runtime for Spring boot microservices" \
	io.openshift.expose-services="8080:https" \
    io.openshift.tags="java8,microservices,spring-boot"

WORKDIR $IMAGE_SCRIPTS_HOME

USER java

CMD [ "./start.sh" ]

