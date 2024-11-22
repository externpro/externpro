ARG BPROTAG=latest
FROM ghcr.io/externpro/buildpro/rocky85-bld:${BPROTAG}
LABEL maintainer="smanders"
LABEL org.opencontainers.image.source=https://github.com/externpro/buildpro
SHELL ["/bin/bash", "-c"]
USER 0
# install node
ENV NODE_VERSION=20.18.0
ENV NVM_DIR=/opt/.nvm
RUN mkdir $NVM_DIR && dnf install -y curl \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
  && dnf clean all
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} \
  && . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION} \
  && . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin/:${PATH}"
# create non-root user, add to sudoers
ARG USERNAME
ARG USERID
ARG GROUPID
RUN if [ ${USERID:-0} -ne 0 ] && [ ${GROUPID:-0} -ne 0 ]; then \
  export GROUPNAME=$(getent group ${GROUPID} | cut -d: -f1) \
  && if [[ -z ${GROUPNAME} ]]; then groupadd -g ${GROUPID} ${USERNAME}; fi \
  && useradd --no-log-init --uid ${USERID} --gid ${GROUPID} ${USERNAME} \
  && echo "" >> /etc/sudoers \
  && echo "## dockerfile adds ${USERNAME} to sudoers" >> /etc/sudoers \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && unset GROUPNAME \
  ; fi
ENV USER=${USERNAME}
# run container as non-root user from here onwards
# so that build output files have the correct owner
USER ${USERNAME}
# run bash script and process the input command
ENTRYPOINT ["/bin/bash", "/usr/local/bpbin/entry.sh"]
