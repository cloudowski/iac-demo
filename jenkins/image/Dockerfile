FROM jenkins/jenkins:2.85

USER root
RUN apt-get update && \
    apt-get install -y \
    git python-virtualenv python-pip python-dev \
    libffi-dev \
    bundler \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Docker 
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
RUN sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && \
    apt-get install -y \
    docker-ce \
    && rm -rf /var/lib/apt/lists/*

COPY myplugins.txt /usr/share/jenkins/
COPY myplugins.sh /usr/local/bin/

USER jenkins

RUN bash -x /usr/local/bin/myplugins.sh
