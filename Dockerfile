# GCC AND PYTHON ARE COPIED FROM OFFICIAL IMAGES FOR SPEED
FROM gcc:15.2-bookworm AS gcc-source
FROM python:3.14.2-slim-bookworm AS python-source
FROM node:24.13.0-bookworm-slim AS node-source
FROM silkeh/clang:21 AS clang-source
FROM eclipse-temurin:21-jdk AS java21-source
FROM eclipse-temurin:25-jdk AS java25-source

FROM buildpack-deps:bookworm-curl

LABEL maintainer="Yozuru"
LABEL description="Judge0 Compilers (Jan 2026)"

RUN set -xe && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential \
  libgmp-dev libmpc-dev libmpfr-dev \
  libffi-dev libssl-dev zlib1g-dev \
  libbz2-dev liblzma-dev libncurses5-dev libsqlite3-dev \
  tk-dev git unzip locales libcap-dev wget && \
  rm -rf /var/lib/apt/lists/* && \
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen


# -----------------------------------------------------------------------------
# Python (3.14.2)
# -----------------------------------------------------------------------------
COPY --from=python-source /usr/local /usr/local
RUN ldconfig

# -----------------------------------------------------------------------------
# Node.js (24.13.0) + Libraries
# -----------------------------------------------------------------------------
COPY --from=node-source /usr/local /usr/local
RUN npm install -g lodash@4.17.21 \
    @datastructures-js/binary-search-tree@5.4.0 \
    @datastructures-js/deque@1.0.8 \
    @datastructures-js/graph@5.3.1 \
    @datastructures-js/heap@4.3.7 \
    @datastructures-js/linked-list@6.1.4 \
    @datastructures-js/priority-queue@6.3.5 \
    @datastructures-js/queue@4.3.0 \
    @datastructures-js/set@4.2.2 \
    @datastructures-js/stack@3.1.6 \
    @datastructures-js/trie@4.2.3
ENV NODE_PATH=/usr/local/lib/node_modules

# -----------------------------------------------------------------------------
# Clang (21)
# -----------------------------------------------------------------------------
COPY --from=clang-source /usr/lib/llvm-21 /usr/lib/llvm-21
COPY --from=clang-source /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=clang-source /usr/lib/clang /usr/lib/clang
COPY --from=clang-source /usr/bin/clang* /usr/bin/
RUN ldconfig

# -----------------------------------------------------------------------------
# Python Libraries
# -----------------------------------------------------------------------------
RUN /usr/local/bin/python3 -m pip install sortedcontainers

# -----------------------------------------------------------------------------
# GCC(15.2)
# -----------------------------------------------------------------------------
COPY --from=gcc-source /usr/local /usr/local
RUN cp /usr/local/lib64/libstdc++.so.6.0.34 /usr/lib/x86_64-linux-gnu/ && \
    cp /usr/local/lib64/libgcc_s.so.1 /usr/lib/x86_64-linux-gnu/ && \
    rm -f /usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
    ln -s libstdc++.so.6.0.34 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
    ldconfig

# -----------------------------------------------------------------------------
# Headers & Scripts
# -----------------------------------------------------------------------------
COPY includes/ /var/local/lib/includes/

# -----------------------------------------------------------------------------
# Java (21)
# -----------------------------------------------------------------------------
COPY --from=java21-source /opt/java/openjdk /usr/local/openjdk21
RUN ln -sf /usr/local/openjdk21/bin/java /usr/local/bin/java && \
    ln -sf /usr/local/openjdk21/bin/javac /usr/local/bin/javac && \
    ln -sf /usr/local/openjdk21/bin/jar /usr/local/bin/jar

# -----------------------------------------------------------------------------
# Java (25)
# -----------------------------------------------------------------------------
COPY --from=java25-source /opt/java/openjdk /usr/local/openjdk25

# -----------------------------------------------------------------------------
# Kotlin
# -----------------------------------------------------------------------------
ENV KOTLIN_VERSIONS="1.9.0 2.3.0"
RUN set -xe && \
  for VERSION in $KOTLIN_VERSIONS; do \
    wget -q https://github.com/JetBrains/kotlin/releases/download/v$VERSION/kotlin-compiler-$VERSION.zip && \
    unzip -q kotlin-compiler-$VERSION.zip && \
    mv kotlinc /usr/local/kotlin-$VERSION && \
    rm kotlin-compiler-$VERSION.zip; \
  done && \
  ln -sf /usr/local/kotlin-2.3.0/bin/kotlinc /usr/local/bin/kotlinc  

# -----------------------------------------------------------------------------
# Isolate
# -----------------------------------------------------------------------------
RUN curl https://www.ucw.cz/isolate/debian/signing-key.asc > /etc/apt/keyrings/isolate.asc && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/isolate.asc] http://www.ucw.cz/isolate/debian/ bookworm-isolate main" > /etc/apt/sources.list.d/isolate.list && \
    apt-get update && \
    apt-get install -y isolate && \
    rm -rf /var/lib/apt/lists/*
ENV BOX_ROOT=/var/local/lib/isolate

RUN echo "=== Build Verification ===" && \
    gcc --version | head -n 1 && \
    python3 --version && \
    bash --version | head -n 1 && \
    java -version && \
    kotlinc -version && \
    node --version && \
    clang --version | head -n 1