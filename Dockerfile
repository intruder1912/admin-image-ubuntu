# kubectl image is used to install kubectl (put into the build cache)
FROM bitnami/kubectl:1.33.0 AS kubectl

# actual base image for the container
FROM ubuntu:24.04
LABEL doblander.org:image-use=admin

#ENV USER=root

# define the non-root user
ARG USERNAME=intruder
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# download the aws-cli
ADD "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" "awscliv2.zip" 

# download the hashicorp gpg key
ADD "https://apt.releases.hashicorp.com/gpg" "hashicorp"

# install kubectl by copying the binary from the kubectl image leveraging multi-stage builds (kubectl image in the cache)
COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/
RUN apt-get update && apt-get upgrade -y \
      # install basic tools
      && apt-get install -y \
         Node.js \
         curl \
         gnupg \
         iproute2 \
         iputils-ping \
         nano \
         net-tools \
         nmap \
         npm \
         pip \
         python-is-python3 \
         software-properties-common \
         sudo \
         unzip \
         vim \
         wget \
         zsh \
      # install terraform
      && gpg --dearmor hashicorp \
      && cp hashicorp.gpg /usr/share/keyrings/hashicorp-archive-keyring.gpg \
      && gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint \  
      && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
      && apt-get update \
      && apt-get install -y \
        terraform \
      # install aws-cdk and aws-cli
      && npm i -g aws-cdk \
      && unzip awscliv2.zip \
      && ./aws/install \
      # add a non-root user with the above specified parameters
      && groupadd --gid "$USER_GID" "$USERNAME" \
      && useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME" \
      && echo "$USERNAME" ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/"$USERNAME" \
      && chmod 0440 /etc/sudoers.d/"$USERNAME" \
      # clean up and minimize the image size
      && apt-get clean \ 
      && rm -rf /var/lib/apt/lists/* 

      # FIXME: provide a defailt zsh profile
      # FIXME: provide a default hosts file adequate for the network address/hostname
      # FIXME: chekc if oh-my-zsh could be installed together with some cool theme

# switch to the non-root user
USER $USERNAME

# start the zsh shell as entry point, so that a different command can only be passed with the --entrypoint flag
ENTRYPOINT [ "/bin/zsh" ]
# no CMD is needed, as the zsh shell will be started without parameters
# CMD [ "-i" ] # this would start the zsh shell in interactive mode