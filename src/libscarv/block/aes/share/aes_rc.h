#ifndef __AES_RC_H
#define __AES_RC_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#if defined( LIBSCARV_CONF_AES_PRECOMP_RC )
extern uint8_t AES_RC[];
#else
#error "no implementation for !defined( LIBSCARV_CONF_AES_PRECOMP_RC )"
#endif

#endif
