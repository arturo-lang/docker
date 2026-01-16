FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        unzip \
        libgmp10 \
        libmpfr6 \
        libgtk-3-0 \
        libwebkit2gtk-4.1-0

RUN curl -sSL https://get.arturo-lang.io | sh

RUN apt-get purge -y curl unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.arturo/bin:${PATH}"

WORKDIR /workspace
ENTRYPOINT ["arturo"]