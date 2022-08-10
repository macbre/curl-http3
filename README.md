# curl-http3
A custom `curl` build with `BoringSSL` and http3 support via `quiche`.

## Usage

```
$ docker run --rm ghcr.io/macbre/curl-http3 curl --version
```

```
$ docker run --rm ghcr.io/macbre/curl-http3 curl -sIL https://blog.cloudflare.com --http3 -H 'user-agent: mozilla'
HTTP/3 200
(...)
```
