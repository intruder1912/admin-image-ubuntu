FROM ubuntu:24.04
LABEL doblander.org:image-use admin
ENV USER root
RUN apt-get update \
      && apt-get upgrade -y \ 
      && apt-get install -y \
        net-tools \
        iputils-ping \
        iproute2 \
        nmap \ 
        curl \
        unzip \
        Node.js \
        npm \
      && apt-get clean \
      && npm i -g aws-cdk
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
      && unzip awscliv2.zip \
      && ./aws/install