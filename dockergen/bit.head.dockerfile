ARG BPROTAG
FROM ghcr.io/externpro/buildpro/%BP_REPO%:${BPROTAG}
LABEL maintainer="smanders"
LABEL org.opencontainers.image.source https://github.com/externpro/buildpro
SHELL ["/bin/bash", "-c"]
USER 0
