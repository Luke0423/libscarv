#ifndef __LIBSCARV_SHA2_256_H
#define __LIBSCARV_SHA2_256_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#define SHA2_256_SIZEOF_BLOCK  ( 64 )
#define SHA2_256_SIZEOF_DIGEST ( 32 )

extern void sha2_256_init();

extern void sha2_256_hash( const uint8_t* m, int n_m );
extern void sha2_256_fini(       uint8_t* d          );

extern void sha2_256( uint8_t* d, int l, ... );

#endif
