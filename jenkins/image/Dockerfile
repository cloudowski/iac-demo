FROM jenkins:2.46.2

USER root
RUN apt-get update && \
    apt-get install -y \
    docker.io git \
    && rm -rf /var/lib/apt/lists/*

COPY myplugins.txt /usr/share/jenkins/
COPY myplugins.sh /usr/local/bin/
USER jenkins 

RUN bash -x /usr/local/bin/myplugins.sh 
