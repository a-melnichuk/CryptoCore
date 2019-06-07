#ifndef CURVE25519_DONNA_H
#define CURVE25519_DONNA_H

#include <stdint.h>
#include <string.h>
#include <stdint.h>

int curve25519_donna(uint8_t *mypublic, const uint8_t *secret, const uint8_t *basepoint);

#endif
