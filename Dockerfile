FROM --platform=linux/arm64 ubuntu:24.04
LABEL doblander.org:image-use admin
ENV USER root
ADD "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" "awscliv2.zip" 
RUN apt-get update \
      && apt-get upgrade -y \ 
      && apt-get install -y \
        Node.js \
        curl \
        iproute2 \
        iputils-ping \
        net-tools \
        nmap \ 
        npm \
        unzip \
      && apt-get clean \
      && npm i -g aws-cdk \
      && unzip awscliv2.zip \
      && ./aws/install