#ifndef PODI_SQI_H
#define PODI_SQI_H

#include <stdint.h>


// Each memory contains 64K bytes.
typedef struct
{
    uint8_t data[64 * 1024];
} sqi_t;

#endif // PODI_SQI_H
