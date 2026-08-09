/* Thin C ABI for the Google WOFF2 encoder and decoder. */

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <string>

#include <emscripten/emscripten.h>
#include <woff2/decode.h>
#include <woff2/encode.h>

extern "C" {

EMSCRIPTEN_KEEPALIVE
auto woff2_compress_bound(const std::uint8_t *input, const std::size_t input_size) -> std::size_t {
    if (input == nullptr || input_size == 0) {
        return 0;
    }
    return woff2::MaxWOFF2CompressedSize(input, input_size);
}

EMSCRIPTEN_KEEPALIVE
auto woff2_compress(const std::uint8_t *input, const std::size_t input_size, std::uint8_t *output,
                    const std::size_t output_capacity) -> std::size_t {
    if (input == nullptr || input_size == 0 || output == nullptr) {
        return 0;
    }

    auto output_size = output_capacity;
    const woff2::WOFF2Params params;
    if (!woff2::ConvertTTFToWOFF2(input, input_size, output, &output_size, params)) {
        return 0;
    }
    return output_size;
}

EMSCRIPTEN_KEEPALIVE
auto woff2_decompressed_size(const std::uint8_t *input, const std::size_t input_size)
    -> std::size_t {
    if (input == nullptr || input_size == 0) {
        return 0;
    }
    return std::min(woff2::ComputeWOFF2FinalSize(input, input_size), woff2::kDefaultMaxSize);
}

EMSCRIPTEN_KEEPALIVE
auto woff2_decompress(const std::uint8_t *input, const std::size_t input_size, std::uint8_t *output,
                      const std::size_t output_capacity) -> std::size_t {
    if (input == nullptr || input_size == 0 || output == nullptr || output_capacity == 0) {
        return 0;
    }

    std::string decoded(output_capacity, '\0');
    woff2::WOFF2StringOut decoded_output(&decoded);
    if (!woff2::ConvertWOFF2ToTTF(input, input_size, &decoded_output) ||
        decoded.size() > output_capacity) {
        return 0;
    }

    std::memcpy(output, decoded.data(), decoded.size());
    return decoded.size();
}

} // extern "C"
