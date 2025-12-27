# GCC AND PYTHON ARE COPIED FROM OFFICIAL IMAGES FOR SPEED
FROM gcc:15.2-bookworm AS gcc-source
FROM python:3.14.2-slim-bookworm AS python-source

FROM buildpack-deps:bookworm-curl

LABEL maintainer="Yozuru"
LABEL description="Judge0 Compilers (Dec 2025)"

RUN set -xe && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential \
  libgmp-dev libmpc-dev libmpfr-dev \
  libffi-dev libssl-dev zlib1g-dev \
  libbz2-dev liblzma-dev libncurses5-dev libsqlite3-dev \
  tk-dev git unzip locales libcap-dev && \
  rm -rf /var/lib/apt/lists/* && \
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8

# -----------------------------------------------------------------------------
# GCC(15.2)
# -----------------------------------------------------------------------------
COPY --from=gcc-source /usr/local /usr/local
RUN ldconfig && \
  ln -s /usr/local/bin/gcc /usr/local/bin/gcc-15 && \
  ln -s /usr/local/bin/g++ /usr/local/bin/g++-15

# -----------------------------------------------------------------------------
# Python(3.14)
# -----------------------------------------------------------------------------
COPY --from=python-source /usr/local /usr/local
RUN ldconfig

# -----------------------------------------------------------------------------
# Bash
# -----------------------------------------------------------------------------
ENV BASH_VERSIONS="5.3" 

RUN set -xe && \
  for VERSION in $BASH_VERSIONS; do \
    echo ">>> Building Bash $VERSION ..." && \
    curl -fSsL "https://ftpmirror.gnu.org/bash/bash-$VERSION.tar.gz" -o /tmp/bash.tar.gz && \
    mkdir -p /tmp/bash-build && \
    tar -xf /tmp/bash.tar.gz -C /tmp/bash-build --strip-components=1 && \
    cd /tmp/bash-build && \
    ./configure --prefix=/usr/local/bash-$VERSION --without-bash-malloc && \
    make -j$(nproc) && \
    make install && \
    ln -s /usr/local/bash-$VERSION/bin/bash /usr/local/bin/bash-$VERSION && \
    cd / && rm -rf /tmp/*; \
  done

# -----------------------------------------------------------------------------
# Java
# -----------------------------------------------------------------------------
ENV JAVA_VERSIONS="21 25"

RUN set -xe && \
  for VERSION in $JAVA_VERSIONS; do \
    echo ">>> Installing Java $VERSION ..." && \
    curl -fSsL "https://download.oracle.com/java/$VERSION/latest/jdk-${VERSION}_linux-x64_bin.tar.gz" -o /tmp/jdk.tar.gz && \
    mkdir -p /usr/local/openjdk$VERSION && \
    tar -xf /tmp/jdk.tar.gz -C /usr/local/openjdk$VERSION --strip-components=1 && \
    rm /tmp/jdk.tar.gz; \
  done && \
  ln -sf /usr/local/openjdk$VERSION/bin/javac /usr/local/bin/javac && \
  ln -sf /usr/local/openjdk$VERSION/bin/java /usr/local/bin/java && \
  ln -sf /usr/local/openjdk$VERSION/bin/jar /usr/local/bin/jar

# -----------------------------------------------------------------------------
# Kotlin
# -----------------------------------------------------------------------------
ENV KOTLIN_VERSIONS="1.9.0 2.3.0"
RUN set -xe && \
    for VERSION in $KOTLIN_VERSIONS; do \
      echo ">>> Installing Kotlin $VERSION ..." && \
      curl -fSsL "https://github.com/JetBrains/kotlin/releases/download/v$VERSION/kotlin-compiler-$VERSION.zip" -o /tmp/kotlin.zip && \
      unzip -q -d /usr/local/ /tmp/kotlin.zip && \
      mv /usr/local/kotlinc /usr/local/kotlin-$VERSION && \
      rm /tmp/kotlin.zip; \
    done && \
    ln -sf /usr/local/kotlin-$VERSION/bin/kotlinc /usr/local/bin/kotlinc

# -----------------------------------------------------------------------------
# Isolate
# -----------------------------------------------------------------------------
RUN set -xe && \
  git clone https://github.com/judge0/isolate.git /tmp/isolate && \
  cd /tmp/isolate && \
  git checkout master && \
  make -j$(nproc) install && \
  rm -rf /tmp/*
ENV BOX_ROOT=/var/local/lib/isolate

RUN echo "=== Build Verification ===" && \
    gcc --version | head -n 1 && \
    python3 --version && \
    bash-5.3 --version | head -n 1 && \
    java -version && \
    kotlinc -version