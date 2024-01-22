ARG BPROTAG
FROM ghcr.io/smanders/buildpro/%BP_REPO%:${BPROTAG}
LABEL maintainer="smanders"
LABEL org.opencontainers.image.source https://github.com/smanders/buildpro
SHELL ["/bin/bash", "-c"]
USER 0
