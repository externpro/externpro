ARG BPROTAG=latest
FROM ghcr.io/externpro/buildpro/rocky85-bld:${BPROTAG}
LABEL maintainer="smanders"
LABEL org.opencontainers.image.source=https://github.com/externpro/buildpro
SHELL ["/bin/bash", "-c"]
USER 0
# [COPY|RUN]_IT
ARG COPY_IT
ARG RUN_IT
COPY ${COPY_IT} /usr/local/games
RUN eval "${RUN_IT}"
# CRTool
ARG CRTOOL
RUN eval "${CRTOOL}"
ENV PATH=$PATH:${EXTERN_DIR}/CRTool
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
# run container as non-root user from here onwards
# so that build output files have the correct owner
USER ${USERNAME}
# run bash script and process the input command
ENTRYPOINT ["/bin/bash", "/usr/local/bpbin/entry.sh"]
