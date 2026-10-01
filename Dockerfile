# kubectl image is used to install kubectl (put into the build cache)
FROM registry.k8s.io/kubectl:v1.37.0 AS kubectl

# actual base image for the container
FROM ubuntu:26.04
LABEL doblander.org:image-use=admin

#ENV USER=root

# Layers are ordered from least to most frequently changing so a change late in
# the file (e.g. a kubectl bump) does not invalidate the heavy layers above it.
# `apt-get upgrade` is cached with its layer; the scheduled CI build runs with
# no-cache to pick up fresh package versions.

# install basic tools
RUN apt-get update && apt-get upgrade -y \
      && apt-get install -y \
         arp-scan \
         atop \
         auditd \
         build-essential \
         chkrootkit \
         clamav \
         curl \
         dnsutils \
         gnupg \
         htop \
         iproute2 \
         iptables \
         iputils-ping \
         jq \
         lsof \
         ltrace \
         lynis \
         mtr \
         nano \
         net-tools \
         netcat-openbsd \
         nmap \
         nodejs \
         npm \
         p7zip-full \
         pip \
         python-is-python3 \
         screen \
         socat \
         software-properties-common \
         strace \
         sudo \
         tcpdump \
         tmux \
         tshark \
         unzip \
         vim \
         whois \
         wget \
         yq \
         zsh \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

# install terraform
ADD "https://apt.releases.hashicorp.com/gpg" "/tmp/hashicorp"
RUN gpg --dearmor /tmp/hashicorp \
      && cp /tmp/hashicorp.gpg /usr/share/keyrings/hashicorp-archive-keyring.gpg \
      && gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint \
      && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
      && apt-get update \
      && apt-get install -y terraform \
      && rm -f /tmp/hashicorp /tmp/hashicorp.gpg \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

# install aws-cli
# TARGETARCH (amd64/arm64) is set by buildx; map it to the AWS CLI archive naming (x86_64/aarch64)
ARG TARGETARCH
RUN AWS_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64" || echo "aarch64") \
      && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o awscliv2.zip \
      && unzip -q awscliv2.zip \
      && ./aws/install \
      && rm -rf awscliv2.zip aws

# install aws-cdk
# call npm through node directly: rust-coreutils' `env` (the `#!/usr/bin/env node` shebang) aborts under QEMU emulation (arm64 on amd64 runners)
RUN node "$(readlink -f "$(command -v npm)")" i -g aws-cdk

# add a non-root user
ARG USERNAME=intruder
ARG USER_UID=1001
ARG USER_GID=$USER_UID
RUN groupadd --gid "$USER_GID" "$USERNAME" \
      && useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME" \
      && echo "$USERNAME" ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/"$USERNAME" \
      && chmod 0440 /etc/sudoers.d/"$USERNAME"

# install kubectl by copying the binary from the kubectl image (kept late: it is bumped most often)
COPY --from=kubectl /bin/kubectl /usr/local/bin/

      # FIXME: provide a defailt zsh profile
      # FIXME: provide a default hosts file adequate for the network address/hostname
      # FIXME: chekc if oh-my-zsh could be installed together with some cool theme

# install the macOS/podman ICMP sanity-check helper (see README "macOS networking caveats")
COPY scripts/icmp-sanity-check /usr/local/bin/icmp-sanity-check
RUN chmod 0755 /usr/local/bin/icmp-sanity-check

# switch to the non-root user
USER $USERNAME

# start the zsh shell as entry point, so that a different command can only be passed with the --entrypoint flag
ENTRYPOINT [ "/bin/zsh" ]
# no CMD is needed, as the zsh shell will be started without parameters
# CMD [ "-i" ] # this would start the zsh shell in interactive mode