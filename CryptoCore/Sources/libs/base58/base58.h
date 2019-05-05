#ifndef LIBBASE58_H
#define LIBBASE58_H

#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <openssl/sha.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    bool b58_sha256_impl(void *out_bytes, const void *in_data, size_t in_length);
    
    bool b58tobin(void *bin, size_t *binsz, const char *b58, size_t b58sz);
    int b58check(const void *bin, size_t binsz, const char *b58, size_t b58sz);
    
    bool b58enc(char *b58, size_t *b58sz, const void *bin, size_t binsz);
    bool b58check_enc(char *b58c, size_t *b58c_sz, uint8_t ver, const void *data, size_t datasz);
    bool b58check_enc_wide(char *b58c, size_t *b58c_sz,
                           const uint8_t* ver, size_t ver_sz,
                           const void *data, size_t datasz);
    
#ifdef __cplusplus
}
#endif

#endif
