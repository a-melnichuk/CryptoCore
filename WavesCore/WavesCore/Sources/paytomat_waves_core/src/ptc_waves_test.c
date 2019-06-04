//
//  ptc_waves_test.c
//  WavesCore
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <paytomat_crypto_core/ptc.h>
#include "ptc_waves_test.h"

int ptc_waves_test_int2(void)
{
    return ptc_test_int();
}

int ptc_waves_test_int(void)
{
    return 5;
}

void ptc_waves_test_print(void)
{
    printf("Test print!\n");
}

ptc_result ptc_waves_test_sha(const void* in_data, size_t in_length, unsigned char* out_data)
{
    return ptc_sha256(in_data, in_length, out_data);
}
