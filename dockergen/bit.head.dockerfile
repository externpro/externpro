ARG BPROTAG=latest
FROM ghcr.io/externpro/buildpro/%BP_REPO%:${BPROTAG}
LABEL maintainer="smanders"
LABEL org.opencontainers.image.source=https://github.com/externpro/buildpro
SHELL ["/bin/bash", "-c"]
USER 0
# [COPY|RUN]_IT
ARG COPY_IT
ARG RUN_IT
COPY ${COPY_IT} /usr/local/games
RUN eval "${RUN_IT}"
