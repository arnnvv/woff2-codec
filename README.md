# woff2-codec

A reproducible build of Google's [WOFF2](https://github.com/google/woff2) encoder and decoder as one standalone WebAssembly binary. The module includes [Brotli](https://github.com/google/brotli) and does not require generated Emscripten JavaScript glue.

This repository does not change Google's compression or decompression logic. It only adds the small interface and build configuration needed to expose both operations from a single `.wasm` file. It is an independent project and is not an official Google project.

Google WOFF2 is pinned to commit: [`a0d0ed7`](https://github.com/google/woff2/commit/a0d0ed7da27b708c0a4e96ad7a998bddc933c06e).

## How the binary is built

1. Emscripten SDK 6.0.6 compiles the Brotli encoder, decoder, and common libraries to WebAssembly-compatible static libraries.
2. The same toolchain compiles Google's WOFF2 encoder, decoder, and common libraries against Brotli.
3. [`src/woff2_wasm.cc`](src/woff2_wasm.cc) adds a numeric ABI around the public Google WOFF2 APIs.
4. Emscripten links everything into one standalone module with exported memory,
   `malloc`, `free`, and memory growth enabled.

## Build

With Docker:

```sh
make build
```

With Podman:

```sh
make build ENGINE=podman
```

The result is in `dist/woff2.wasm`. The build runs entirely inside the container; no local Emscripten installation is required.

Format the C++ bridge with:

```sh
make format
```

Check formatting without changing the file with `make check-format`.

## WASM ABI

The module exports `memory`, `malloc`, `free`, and:

- `woff2_compress_bound(input, input_length)`
- `woff2_compress(input, input_length, output, output_capacity)`
- `woff2_decompressed_size(input, input_length)`
- `woff2_decompress(input, input_length, output, output_capacity)`

The transform functions return the written byte length or zero on failure.

## Prebuilt binary

`dist/woff2.wasm` SHA-256:

```text
33927947424b7c53fd685fe2f2197b1dd6787468460c0afad7ec950d4c972eb7
```

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the Google WOFF2 and Brotli attribution and license notices.
