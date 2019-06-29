//
//  ptc_buffer.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_BUFFER_H
#define PTC_BUFFER_H

#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct ptc_buffer {
    uint8_t* data;
    size_t length;
} ptc_buffer;

void ptc_buffer_init(ptc_buffer* buffer);
bool ptc_buffer_create(ptc_buffer* buffer, size_t length);
bool ptc_buffer_create_copy(ptc_buffer* buffer, const uint8_t* bytes, size_t length);
void ptc_buffer_destroy(ptc_buffer* buffer);

#endif
