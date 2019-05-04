#ifndef _BLAKE2B_H
#define _BLAKE2B_H

#include "blake2b_crypto.h"

//BLAKE2b block size
#define BLAKE2B_BLOCK_SIZE 128

typedef struct
{
   union
   {
      uint64_t h[8];
      uint8_t digest[64];
   };
   union
   {
      uint64_t m[16];
      uint8_t buffer[128];
   };
   size_t size;
   uint64_t totalSize[2];
   size_t digestSize;
} Blake2bContext;


//BLAKE2b related functions
error_t blake2bCompute(const void *key, size_t keyLen, const void *data,
   size_t dataLen, uint8_t *digest, size_t digestLen);

error_t blake2bInit(Blake2bContext *context, const void *key,
   size_t keyLen, size_t digestLen);

void blake2bUpdate(Blake2bContext *context, const void *data, size_t length);
void blake2bFinal(Blake2bContext *context, uint8_t *digest);
void blake2bProcessBlock(Blake2bContext *context, bool_t last);

#endif
