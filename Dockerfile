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
      # chkrootkit only *recommends* a mail agent, which pulls in postfix (a mail daemon plus
      # a generated TLS private key via ssl-cert). nothing here needs it, so drop it again
      && apt-get purge -y postfix bsd-mailx ssl-cert \
      && apt-get autoremove -y --purge \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

# install terraform
# the downloaded apt repository key is only trusted if it is HashiCorp's package signing key, see
# https://www.hashicorp.com/en/trust/security (rotated in 2026-09: update the fingerprint on the next rotation)
ARG HASHICORP_APT_KEY_FPR=D55C0D1AC78A8D8126CB631CFC9CA96ACA026560
ADD "https://apt.releases.hashicorp.com/gpg" "/tmp/hashicorp"
RUN gpg --dearmor /tmp/hashicorp \
      && cp /tmp/hashicorp.gpg /usr/share/keyrings/hashicorp-archive-keyring.gpg \
      && ACTUAL_FPR="$(gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --with-colons --fingerprint | awk -F: '/^pub:/{p=1;next} p&&/^fpr:/{print $10;p=0}')" \
      && { [ "$ACTUAL_FPR" = "$HASHICORP_APT_KEY_FPR" ] || { echo "unexpected HashiCorp apt key: ${ACTUAL_FPR}"; exit 1; }; } \
      && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
      && apt-get update \
      && apt-get install -y terraform \
      && rm -f /tmp/hashicorp /tmp/hashicorp.gpg \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

# install aws-cli
# TARGETARCH (amd64/arm64) is set by buildx; map it to the AWS CLI archive naming (x86_64/aarch64)
# the zip is verified against AWS's detached PGP signature with the AWS CLI team key
# (keys/awscli-public-key.asc, copied from the AWS CLI install docs). that key expires 2027-07-01:
# if verification starts failing, refresh the file and fingerprint from the docs
ARG TARGETARCH
ARG AWSCLI_KEY_FPR=FB5DB77FD5C118B80511ADA8A6310ACC4672475C
COPY keys/awscli-public-key.asc /tmp/awscli-public-key.asc
RUN AWS_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64" || echo "aarch64") \
      && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o awscliv2.zip \
      && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip.sig" -o awscliv2.sig \
      && export GNUPGHOME="$(mktemp -d)" \
      && gpg --batch --import /tmp/awscli-public-key.asc \
      && ACTUAL_FPR="$(gpg --batch --with-colons --fingerprint | awk -F: '/^fpr:/{print $10; exit}')" \
      && { [ "$ACTUAL_FPR" = "$AWSCLI_KEY_FPR" ] || { echo "unexpected AWS CLI key: ${ACTUAL_FPR}"; exit 1; }; } \
      && gpg --batch --verify awscliv2.sig awscliv2.zip \
      && unzip -q awscliv2.zip \
      && ./aws/install \
      && rm -rf awscliv2.zip awscliv2.sig aws /tmp/awscli-public-key.asc "$GNUPGHOME"

# install aws-cdk
# the exact version is pinned in tools/aws-cdk/package.json, which Dependabot (npm ecosystem) keeps up to date
# call npm through node directly: rust-coreutils' `env` (the `#!/usr/bin/env node` shebang) aborts under QEMU emulation (arm64 on amd64 runners)
COPY tools/aws-cdk/package.json /tmp/aws-cdk-package.json
RUN AWS_CDK_VERSION="$(jq -er '.dependencies["aws-cdk"]' /tmp/aws-cdk-package.json)" \
      && { echo "$AWS_CDK_VERSION" | grep -Eqx '[0-9]+\.[0-9]+\.[0-9]+' || { echo "aws-cdk must be pinned to an exact version, got: ${AWS_CDK_VERSION}"; exit 1; }; } \
      && node "$(readlink -f "$(command -v npm)")" i -g "aws-cdk@${AWS_CDK_VERSION}" \
      && rm -f /tmp/aws-cdk-package.json

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