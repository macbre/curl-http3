# curl-http3
[![Docker Image CI](https://github.com/macbre/curl-http3/actions/workflows/dockerimage.yml/badge.svg)](https://github.com/macbre/curl-http3/actions/workflows/dockerimage.yml)

A custom `curl` build with `brotli`, `BoringSSL` and `http3` support (via `quiche`) in **under 50MB container image**.

```
curl 8.15.0-DEV (x86_64-pc-linux-musl) libcurl/8.15.0-DEV BoringSSL zlib/1.2.12 brotli/1.1.0 libidn2/2.3.7 libpsl/0.21.5 nghttp2/1.65.0 quiche/0.24.5
Release-Date: [unreleased]
Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns mqtt pop3 pop3s rtsp smb smbs smtp smtps telnet tftp ws wss
Features: alt-svc AsynchDNS brotli HSTS HTTP2 HTTP3 HTTPS-proxy IDN IPv6 Largefile libz NTLM PSL SSL threadsafe UnixSockets
```

## Usage

```
$ docker run --rm ghcr.io/macbre/curl-http3 curl --version
```

```
$ docker run --rm ghcr.io/macbre/curl-http3 curl -sIL https://blog.cloudflare.com --http3 -H 'user-agent: mozilla'
HTTP/3 200
(...)
```
