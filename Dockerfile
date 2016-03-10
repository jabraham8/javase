FROM centos:7
MAINTAINER BOL Paradigma carrefour-bol@paradigmadigital.com

#ADD local.repo /etc/yum.repos.d/
ADD application.jar /

ENV JAVA_VERSION 1.8.0
##ENV GID 20000
##ENV UID 20000

ENV APP_HOME /opt/app 
ENV IMAGE_SCRIPTS_HOME /opt/produban

RUN mkdir -p $APP_HOME && \
	mkdir $IMAGE_SCRIPTS_HOME && \
    mkdir -p $IMAGE_SCRIPTS_HOME/bin

COPY Dockerfile $IMAGE_SCRIPTS_HOME/Dockerfile
COPY java-buildpack-memory-calculator $IMAGE_SCRIPTS_HOME/bin/java-buildpack-memory-calculator

##RUN groupadd --gid $GID java && useradd --uid $UID -m -g java java && \
RUN yum -y install \
       java-$JAVA_VERSION-openjdk-devel \
       procps-ng \
       strace \
       unzip \
       wget && \
    yum clean all

ADD scripts $IMAGE_SCRIPTS_HOME 

##RUN chown -R java:java $APP_HOME && \
##    chown -R java:java $IMAGE_SCRIPTS_HOME
RUN chown -R 1001:1001 $APP_HOME && \
    chown -R 1001:1001 $IMAGE_SCRIPTS_HOME	
	

EXPOSE 8080
#######################################################################
##### We have to expose image metada as label and ENV 
#######################################################################
LABEL com.produban.imageowner="Products and Services" \
      com.produban.description="Java 8 runtime for Spring boot microservices" \
      com.produban.components="java8"

ENV com.produban.imageowner="Products and Services" \
    com.produban.description="Java 8 runtime for Spring boot microservices" \
    com.produban.components="java8"

##USER java

RUN chmod -R +x $IMAGE_SCRIPTS_HOME
##RUN export PATH=$PATH:$IMAGE_SCRIPTS_HOME
WORKDIR $IMAGE_SCRIPTS_HOME

USER 1001

ENTRYPOINT [ "./control.sh" ]
CMD [ "start" ]

