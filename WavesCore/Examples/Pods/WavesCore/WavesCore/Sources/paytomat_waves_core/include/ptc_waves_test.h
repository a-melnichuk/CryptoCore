//
//  ptc_waves_test.h
//  WavesCore
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef ptc_waves_test_h
#define ptc_waves_test_h

#include <stdio.h>
#include <paytomat_crypto_core/ptc_result.h>

int ptc_waves_test_int(void);
int ptc_waves_test_int2(void);
void ptc_waves_test_print(void);
ptc_result ptc_waves_test_sha(const void* in_data, size_t in_length, unsigned char* out_data);

#endif
