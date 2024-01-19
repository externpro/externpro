ARG BPROTAG
FROM ghcr.io/smanders/buildpro/rocky85-bld:${BPROTAG}
LABEL maintainer="smanders"
LABEL org.opencontainers.image.source https://github.com/smanders/buildpro
SHELL ["/bin/bash", "-c"]
USER 0
# build docker image offline support
ARG ADDSRC1 ADDSRC2
ADD ${ADDSRC1} ${ADDSRC2} ${EXTERN_DIR}/
# later browsers
ARG LATER_CHROME
RUN eval "${LATER_CHROME}"
ARG LATER_FIREFOX
RUN eval "${LATER_FIREFOX}"
# CRTool
ARG CRTOOL
RUN eval "${CRTOOL}"
ENV PATH=$PATH:${EXTERN_DIR}/CRTool
# PluginSDK
ARG PLUGINSDK
RUN eval "${PLUGINSDK}"
# internpro
ARG INTERNPRO
RUN eval "${INTERNPRO}"
ARG INTERNPRO_PATH="${EXTERN_DIR}/internpro*"
ENV INTERNPRO_PATH=${INTERNPRO_PATH}
# webpro
ARG WEBPRO
RUN eval "${WEBPRO}"
ARG WEBPRO_PATH="${EXTERN_DIR}/webpro*"
ENV WEBPRO_PATH=${WEBPRO_PATH}
# timezone
ARG TZ
ENV TZ=$TZ
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
# docker group
ARG DOCKGID
RUN if [ ${DOCKGID:-0} -ne 0 ] && [ -x "$(command -v docker)" ]; then \
  getent group ${DOCKGID} || groupadd -g ${DOCKGID} bpdocker; \
  usermod -aG ${DOCKGID} ${USERNAME}; \
  fi
# run container as non-root user from here onwards
# so that build output files have the correct owner
USER ${USERNAME}
# run bash script and process the input command
ENTRYPOINT ["/bin/bash", "/usr/local/bpbin/entry.sh"]
