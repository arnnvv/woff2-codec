FROM emscripten/emsdk:6.0.6

ARG WOFF2_COMMIT=a0d0ed7da27b708c0a4e96ad7a998bddc933c06e

RUN git clone --recursive https://github.com/google/woff2.git /src/woff2 && \
    cd /src/woff2 && \
    git checkout "$WOFF2_COMMIT"

RUN mkdir -p /src/build/brotli && \
    cd /src/build/brotli && \
    emcmake cmake /src/woff2/brotli -DCMAKE_BUILD_TYPE=Release && \
    emmake make -j4 brotlienc-static brotlidec-static brotlicommon-static

RUN mkdir -p /src/build/woff2 && \
    cd /src/build/woff2 && \
    emcmake cmake /src/woff2 \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=OFF \
      -DNOISY_LOGGING=OFF \
      -DBROTLIENC_INCLUDE_DIRS=/src/woff2/brotli/c/include/ \
      -DBROTLIDEC_INCLUDE_DIRS=/src/woff2/brotli/c/include/ \
      -DBROTLIENC_LIBRARIES=/src/build/brotli/libbrotlienc-static.a \
      -DBROTLIDEC_LIBRARIES=/src/build/brotli/libbrotlidec-static.a && \
    emmake make -j4 woff2enc woff2dec

COPY src/woff2_wasm.cc /src/woff2_wasm.cc

RUN em++ -std=c++26 -O3 -DNDEBUG \
      -Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion -Werror \
      --no-entry \
      -s STANDALONE_WASM=1 \
      -s ALLOW_MEMORY_GROWTH=1 \
      -s EXPORTED_FUNCTIONS="['_malloc','_free','_woff2_compress_bound','_woff2_compress','_woff2_decompressed_size','_woff2_decompress']" \
      -I/src/woff2/include/ \
      -o /src/build/woff2.wasm \
      /src/woff2_wasm.cc \
      /src/build/woff2/libwoff2enc.a \
      /src/build/woff2/libwoff2dec.a \
      /src/build/woff2/libwoff2common.a \
      /src/build/brotli/libbrotlienc-static.a \
      /src/build/brotli/libbrotlidec-static.a \
      /src/build/brotli/libbrotlicommon-static.a

CMD ["cp", "/src/build/woff2.wasm", "/out/woff2.wasm"]
