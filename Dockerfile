# https://github.com/curl/curl/releases 
ARG CURL_VERSION=curl-8_15_0
# https://github.com/cloudflare/quiche/releases
ARG QUICHE_VERSION=0.24.5

FROM alpine:3.22 AS base

ARG CURL_VERSION
ARG QUICHE_VERSION

LABEL maintainer="macbre <maciej.brencz@gmail.com>"
WORKDIR /opt

# install dependency
RUN apk add --no-cache \
  autoconf \
  automake \
  brotli-dev \
  build-base \
  cmake \
  git \
  libtool \
  libpsl-dev \
  nghttp2-dev \
  pkgconfig \
  wget \
  zlib-dev

# set up our home directory
RUN mkdir -p /root
ENV HOME /root

# set up Rust
RUN wget https://sh.rustup.rs -O - | sh -s -- -y

ENV PATH "${PATH}:$HOME/.cargo/bin"
RUN cargo --version; rustc --version

# @see https://curl.se/docs/http3.html#quiche-version
RUN \
  echo "Building quiche ${QUICHE_VERSION} ..." && \
  git clone -b ${QUICHE_VERSION} --depth 1 --single-branch https://github.com/cloudflare/quiche.git && \
  cd quiche && \
  git submodule init && \
  git submodule update && \
  cargo build --package quiche --release --features ffi,pkg-config-meta,qlog

RUN \
  mkdir /opt/quiche/quiche/deps/boringssl/src/lib/ && \
  ln -vnf $(find ./quiche/target/release/build/ -name libcrypto.a -o -name libssl.a) /opt/quiche/quiche/deps/boringssl/src/lib/

RUN \
  cd /opt && \
  echo "Building ${CURL_VERSION} ..." && \
  git clone -b ${CURL_VERSION} --depth 1 --single-branch https://github.com/curl/curl && \
  cd curl && \
  autoreconf -fi && \
  ./configure LDFLAGS="-Wl,-rpath,/opt/quiche/target/release" \
    --with-brotli \
    --with-nghttp2 \
    --with-openssl=/opt/quiche/quiche/deps/boringssl/src \
    --with-quiche=/opt/quiche/target/release \
    --with-zlib && \
  make && \
  make install

# so that we know what to copy over from the "base" stage
RUN ldd $(which curl)

# make our resulting image way smaller
# from 2.85GB to 44.9MB
FROM alpine:3.16

ARG CURL_VERSION
ARG QUICHE_VERSION

ENV CURL_VERSION   $CURL_VERSION
ENV QUICHE_VERSION $QUICHE_VERSION

# Copy over required dependencies
COPY --from=base /usr/local/bin/curl /usr/local/bin/curl
COPY --from=base /usr/local/lib/libcurl.so.4 /usr/local/lib/libcurl.so.4
COPY --from=base /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1
COPY --from=base /usr/lib/libnghttp2.so.14 /usr/lib/libnghttp2.so.14
COPY --from=base /usr/lib/libbrotlidec.so.1 /usr/lib/libbrotlidec.so.1
COPY --from=base /usr/lib/libz.so.1 /usr/lib/libz.so.1
COPY --from=base /usr/lib/libbrotlicommon.so.1 /usr/lib/libbrotlicommon.so.1
COPY --from=base /usr/lib/libpsl.so.5 /usr/lib/libpsl.so.5
COPY --from=base /usr/lib/libidn2.so.0 /usr/lib/libidn2.so.0

# we do not need root anymore
USER nobody
RUN env | sort; which curl; curl --version
