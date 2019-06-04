//
//  crypto.h
//  acw
//
//  Created by Alex Melnichuk on 3/5/18.
//  Copyright © 2018 Alex Melnichuk. All rights reserved.
//

#ifndef _CRYPTO_OPEN_H
#define _CRYPTO_OPEN_H

#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "blake2b_error.h"
#include "blake2b_cpu_endian.h"

#ifndef TRUE
    #define TRUE 1
#endif

#ifndef FALSE
    #define FALSE 0
#endif

#ifndef MIN
    #define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif

//Rotate left operation

#define ROL8(a, n) (((a) << (n)) | ((a) >> (8 - (n))))

#define ROL16(a, n) (((a) << (n)) | ((a) >> (16 - (n))))

#define ROL32(a, n) (((a) << (n)) | ((a) >> (32 - (n))))

#define ROL64(a, n) (((a) << (n)) | ((a) >> (64 - (n))))

//Rotate right operation
#define ROR8(a, n) (((a) >> (n)) | ((a) << (8 - (n))))

#define ROR16(a, n) (((a) >> (n)) | ((a) << (16 - (n))))

#define ROR32(a, n) (((a) >> (n)) | ((a) << (32 - (n))))

#define ROR64(a, n) (((a) >> (n)) | ((a) << (64 - (n))))

//Shift left operation
#define SHL8(a, n) ((a) << (n))

#define SHL16(a, n) ((a) << (n))

#define SHL32(a, n) ((a) << (n))

#define SHL64(a, n) ((a) << (n))

//Shift right operation
#define SHR8(a, n) ((a) >> (n))

#define SHR16(a, n) ((a) >> (n))

#define SHR32(a, n) ((a) >> (n))

#define SHR64(a, n) ((a) >> (n))

//Common API for hash algorithms

#if !defined(R_TYPEDEFS_H) && !defined(USE_CHIBIOS_2)
    typedef int bool_t;
#endif

typedef char char_t;
typedef signed int int_t;
typedef unsigned int uint_t;
typedef error_t (*HashAlgoCompute)(const void *data, size_t length, uint8_t *digest);
typedef void (*HashAlgoInit)(void *context);
typedef void (*HashAlgoUpdate)(void *context, const void *data, size_t length);
typedef void (*HashAlgoFinal)(void *context, uint8_t *digest);

/**
 * @brief Common interface for hash algorithms
 **/

typedef struct
{
    const char_t *name;
    const uint8_t *oid;
    size_t oidSize;
    size_t contextSize;
    size_t blockSize;
    size_t digestSize;
    HashAlgoCompute compute;
    HashAlgoInit init;
    HashAlgoUpdate update;
    HashAlgoFinal final;
} HashAlgo;

#endif
