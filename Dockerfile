FROM --platform="linux/arm64" ubuntu:24.04
LABEL doblander.org:image-use=admin
ENV USER=root
ADD "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" "awscliv2.zip" 
ADD "https://apt.releases.hashicorp.com/gpg" "hashicorp"
RUN apt-get update && apt-get upgrade -y \
      && apt-get install -y \
         Node.js \
         curl \
         gnupg \
         iproute2 \
         iputils-ping \
         net-tools \
         nmap \
         npm \
         software-properties-common \
         unzip \
      && gpg --dearmor hashicorp \
      && cp hashicorp.gpg /usr/share/keyrings/hashicorp-archive-keyring.gpg \
      && gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint \  
      && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
      && apt-get update \
      && apt-get install -y \
        terraform \
      && npm i -g aws-cdk \
      && unzip awscliv2.zip \
      && ./aws/install \
      && apt-get clean \ 
      && rm -rf /var/lib/apt/lists/* 