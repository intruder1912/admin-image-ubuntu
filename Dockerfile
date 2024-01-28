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
    && apt-get clean

