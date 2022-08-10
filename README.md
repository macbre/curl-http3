# curl-http3
A custom `curl` build with `BoringSSL` and http3 support via `quiche` in **under 50MB container image**.

```
curl 7.84.0-DEV (x86_64-pc-linux-musl) libcurl/7.84.0-DEV BoringSSL quiche/0.14.0
Release-Date: [unreleased]
Protocols: dict file ftp ftps gopher gophers http https imap imaps mqtt pop3 pop3s rtsp smb smbs smtp smtps telnet tftp 
Features: alt-svc AsynchDNS HSTS HTTP3 HTTPS-proxy IPv6 Largefile NTLM NTLM_WB SSL threadsafe UnixSockets
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
