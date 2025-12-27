FROM buildpack-deps:bookworm-curl

LABEL maintainer="Yozuru"
LABEL description="Judge0 Modern Compilers (Dec 2025) - GCC 15, Java 25, Py 3.14"

RUN set -xe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        automake \
        bison \
        flex \
        gperf \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        texinfo \
        zlib1g-dev \
        libssl-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        git \
        unzip \
        libcap-dev && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# C & C++ (GCC 15.2.0)
# -----------------------------------------------------------------------------
ENV GCC_VERSIONS \
      15.2.0
RUN set -xe && \
    for VERSION in $GCC_VERSIONS; do \
      curl -fSsL "https://ftpmirror.gnu.org/gcc/gcc-$VERSION/gcc-$VERSION.tar.xz" -o /tmp/gcc-$VERSION.tar.xz && \
      mkdir /tmp/gcc-$VERSION && \
      tar -xf /tmp/gcc-$VERSION.tar.xz -C /tmp/gcc-$VERSION --strip-components=1 && \
      cd /tmp/gcc-$VERSION && \
      ./contrib/download_prerequisites && \
      mkdir build && cd build && \
      ../configure \
        --disable-multilib \
        --enable-languages=c,c++ \
        --disable-bootstrap \
        --with-system-zlib \
        --prefix=/usr/local/gcc-$VERSION && \
      make -j$(nproc) && \
      make -j$(nproc) install-strip && \
      ln -s /usr/local/gcc-$VERSION/bin/gcc /usr/local/bin/gcc && \
      ln -s /usr/local/gcc-$VERSION/bin/g++ /usr/local/bin/g++ && \
      cd / && rm -rf /tmp/*; \
    done

# -----------------------------------------------------------------------------
# Java (OpenJDK 25)
# -----------------------------------------------------------------------------
RUN set -xe && \
    curl -fSsL "https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz" -o /tmp/jdk.tar.gz && \
    mkdir -p /usr/local/openjdk25 && \
    tar -xf /tmp/jdk.tar.gz -C /usr/local/openjdk25 --strip-components=1 && \
    rm /tmp/jdk.tar.gz && \
    ln -s /usr/local/openjdk25/bin/javac /usr/local/bin/javac && \
    ln -s /usr/local/openjdk25/bin/java /usr/local/bin/java && \
    ln -s /usr/local/openjdk25/bin/jar /usr/local/bin/jar

# -----------------------------------------------------------------------------
# Python (3.14.2)
# -----------------------------------------------------------------------------
ENV PYTHON_VERSIONS \
      3.14.2
RUN set -xe && \
    for VERSION in $PYTHON_VERSIONS; do \
      curl -fSsL "https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tar.xz" -o /tmp/python-$VERSION.tar.xz && \
      mkdir /tmp/python-$VERSION && \
      tar -xf /tmp/python-$VERSION.tar.xz -C /tmp/python-$VERSION --strip-components=1 && \
      cd /tmp/python-$VERSION && \
      ./configure \
        --enable-optimizations \
        --with-lto \
        --prefix=/usr/local/python-$VERSION && \
      make -j$(nproc) && \
      make -j$(nproc) install && \
      ln -s /usr/local/python-$VERSION/bin/python3 /usr/local/bin/python3 && \
      rm -rf /tmp/*; \
    done

# -----------------------------------------------------------------------------
# 5. Bash (5.3)
# -----------------------------------------------------------------------------
ENV BASH_VERSIONS \
      5.3
RUN set -xe && \
    for VERSION in $BASH_VERSIONS; do \
      curl -fSsL "https://ftpmirror.gnu.org/bash/bash-$VERSION.tar.gz" -o /tmp/bash-$VERSION.tar.gz && \
      mkdir /tmp/bash-$VERSION && \
      tar -xf /tmp/bash-$VERSION.tar.gz -C /tmp/bash-$VERSION --strip-components=1 && \
      cd /tmp/bash-$VERSION && \
      ./configure \
        --prefix=/usr/local/bash-$VERSION && \
      make -j$(nproc) && \
      make -j$(nproc) install && \
      ln -s /usr/local/bash-$VERSION/bin/bash /usr/local/bin/bash-5.3 && \
      rm -rf /tmp/*; \
    done

# -----------------------------------------------------------------------------
# 6. Kotlin (2.3.0)
# -----------------------------------------------------------------------------
ENV KOTLIN_VERSION=2.3.0
RUN set -xe && \
    curl -fSsL "https://github.com/JetBrains/kotlin/releases/download/v$KOTLIN_VERSION/kotlin-compiler-$KOTLIN_VERSION.zip" -o /tmp/kotlin.zip && \
    unzip -d /usr/local/ /tmp/kotlin.zip && \
    mv /usr/local/kotlinc /usr/local/kotlin-$KOTLIN_VERSION && \
    rm /tmp/kotlin.zip && \
    ln -s /usr/local/kotlin-$KOTLIN_VERSION/bin/kotlinc /usr/local/bin/kotlinc

# -----------------------------------------------------------------------------
# Isolate
# -----------------------------------------------------------------------------
RUN set -xe && \
    git clone https://github.com/judge0/isolate.git /tmp/isolate && \
    cd /tmp/isolate && \
    git checkout master && \
    make -j$(nproc) install && \
    rm -rf /tmp/*
ENV BOX_ROOT /var/local/lib/isolate

RUN set -xe && \
    apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

ENV LD_LIBRARY_PATH=/usr/local/gcc-15.2.0/lib64:$LD_LIBRARY_PATH