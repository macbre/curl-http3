FROM alpine:3.14 AS base

LABEL maintainer="macbre <maciej.brencz@gmail.com>"

WORKDIR /opt

# https://github.com/curl/curl/releases 
ARG CURL_VERSION=curl-7_84_0
# https://github.com/cloudflare/quiche/releases
ARG QUICHE_VERSION=0.14.0

# install dependency
RUN apk add --no-cache \
  autoconf \
  automake \
  build-base \
  cmake \
  curl \
  git \
  libtool \
  pkgconfig

# set up our home directory
RUN mkdir -p /root
ENV HOME /root

# set up Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH "${PATH}:$HOME/.cargo/bin"
RUN cargo --version; rustc --version

# @see https://curl.se/docs/http3.html#quiche-version
RUN \
  echo "Building quiche ${QUICHE_VERSION} ..." && \
  git clone -b ${QUICHE_VERSION} --depth 1 --single-branch https://github.com/cloudflare/quiche.git && \
  cd quiche && \
  git submodule init && \
  git submodule update && \
  cargo build --package quiche --release --features ffi,pkg-config-meta,qlog && \
  mkdir /opt/quiche/quiche/deps/boringssl/src/lib/ && \
  ln -vnf $(find ./quiche/target/release/build/ -name libcrypto.a -o -name libssl.a) /opt/quiche/quiche/deps/boringssl/src/lib/

RUN \
  cd /opt && \
  echo "Building ${CURL_VERSION} ..." && \
  git clone -b ${CURL_VERSION} --depth 1 --single-branch https://github.com/curl/curl && \
  cd curl && \
  autoreconf -fi && \
  ./configure LDFLAGS="-Wl,-rpath,/opt/quiche/target/release" --with-openssl=/opt/quiche/quiche/deps/boringssl/src --with-quiche=/opt/quiche/target/release && \
  make && \
  make install

# we do not need root anymore
USER nobody

# TODO: use multi stages to make the image smaller
RUN env | sort; which curl; curl --version
