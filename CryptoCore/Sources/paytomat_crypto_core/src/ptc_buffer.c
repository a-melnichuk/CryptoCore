//
//  ptc_buffer.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include "ptc_buffer.h"

void ptc_buffer_init(ptc_buffer* buffer)
{
    if (buffer == NULL)
        return;
    buffer->data = NULL;
    buffer->length = 0;
}

bool ptc_buffer_create(ptc_buffer* buffer, size_t length)
{
    if (buffer == NULL)
        return false;
    if ((buffer->data = calloc(length, sizeof(uint8_t))) == NULL)
        return false;
    buffer->length = length;
    return true;
}

bool ptc_buffer_create_copy(ptc_buffer* buffer, const uint8_t* bytes, size_t length)
{
    if (buffer == NULL)
        return false;
    if ((buffer->data = malloc(length)) == NULL)
        return false;
    memcpy(buffer->data, bytes, length);
    buffer->length = length;
    return true;
}

void ptc_buffer_destroy(ptc_buffer* buffer)
{
    if (buffer == NULL)
        return;
    buffer->length = 0;
    if (buffer->data != NULL) {
        memset(buffer->data, 0, buffer->length);
        free(buffer->data);
    }
}
