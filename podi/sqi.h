#ifndef PODI_SQI_H
#define PODI_SQI_H

#include <stdint.h>
#include <string.h>

#include "sqi.pio.h"


// Only support the READ/WRITE commands.
typedef enum
{
    SQI_MODE_WRITE = 0x2,
    SQI_MODE_READ  = 0x3,
} sqi_mode_t;


// Current state.
typedef enum
{
    SQI_STATE_INSTR,
    SQI_STATE_ADDR_HI,
    SQI_STATE_ADDR_LO,
    SQI_STATE_RX,
    SQI_STATE_TX_HI,
    SQI_STATE_TX_LO,
} sqi_state_t;


// Each memory contains 64K bytes of data, an address, and the mode.
// Extra PIO specific info is also maintained.
typedef struct
{
    sqi_mode_t  mode;
    uint16_t    addr;
    sqi_state_t state;
    uint8_t     data[64 * 1024];
    PIO         pio;
    uint        offset;
    uint        sm;
    io_rw_8     *txf;
    io_rw_8     *rxf;
    uint        cs;
} sqi_t;


// Create a new SQI instance using the specified pins.
static inline void sqi_init(sqi_t *sqi, PIO pio, uint sio0, uint cs)
{
    memset(sqi, 0, sizeof *sqi);

    sqi->cs = cs;

    sqi->pio = pio;
    sqi->offset = pio_add_program(pio, &sqi_program);
    sqi->sm = pio_claim_unused_sm(pio, true);

    sqi->txf = (io_rw_8 *)&pio->txf[sqi->sm];
    sqi->rxf = (io_rw_8 *)&pio->rxf[sqi->sm];

    // Configure and start the PIO.
    sqi_pio_init(pio, sqi->sm, sqi->offset, sio0, cs);

    // Send two iterations worth of zero data to stay in IN mode until the first
    // 8b of RX data has arrived.
    *sqi->txf = 0;
    *sqi->txf = 0;
}

// Single update cycle for the state machine.
static inline void sqi_tick(sqi_t *sqi)
{
    // If CS is pulled high then reset all state.
    if (gpio_get(sqi->cs))
    {
        pio_sm_clear_fifos(sqi->pio, sqi->sm);
        sqi->state = SQI_STATE_INSTR;
        return;
    }

    // If there's nothing to read then try again next tick.
    if (pio_sm_is_rx_fifo_empty(sqi->pio, sqi->sm))
    {
        return;
    }

    // Grab the next 8b of data from the RX FIFO.
    const uint8_t rx = *sqi->rxf;

    // If waiting for instruction then parse it and set mode appropriately.
    if (sqi->state == SQI_STATE_INSTR)
    {
        sqi->mode = rx;

        if (sqi->mode != SQI_MODE_READ && sqi->mode != SQI_MODE_WRITE)
        {
            stdio_printf("ERROR: Bad SQI mode: 0x%02x\n", rx);
            return;
        }

        stdio_printf("SQI: mode=0x%02x\n", rx);

        // Next we'll need to wait for the address to clock in, so update state
        // and stay in IN mode for another 8b.
        sqi->state = SQI_STATE_ADDR_HI;
        *sqi->txf = 0;
        *sqi->txf = 0;
        return;
    }

    // Receive first 8b of address.
    if (sqi->state == SQI_STATE_ADDR_HI)
    {
        sqi->addr = rx;
        sqi->state = SQI_STATE_ADDR_LO;
        *sqi->txf = 0;
        *sqi->txf = 0;
        return;
    }

    // Receive final 8b of address.
    if (sqi->state == SQI_STATE_ADDR_LO)
    {
        sqi->addr = (sqi->addr << 8) | rx;

        stdio_printf("SQI: addr=0x%04x\n", sqi->addr);

        // If READ send out dummy byte then get ready TX.
        // If WRITE remain in RX.
        if (sqi->mode == SQI_MODE_READ)
        {
            sqi->state = SQI_STATE_TX_HI;
            *sqi->txf = 1;
            *sqi->txf = 1;
        }
        else
        {
            sqi->state = SQI_STATE_RX;
            *sqi->txf = 0;
            *sqi->txf = 0;
        }

        return;
    }

    // If RX store new data into the memory.
    if (sqi->state == SQI_STATE_RX)
    {
        stdio_printf("SQI: RX addr=0x%04x data=0x%02x\n", sqi->addr, rx);
        sqi->data[sqi->addr++] = rx;

        *sqi->txf = 0;
        *sqi->txf = 0;

        return;
    }

    // Remaining states are all sending data so need to wait for there to be
    // enough space in the FIFO.
    if (!pio_sm_is_tx_fifo_empty(sqi->pio, sqi->sm))
    {
        return;
    }

    // Send out the top or bottom nibble.
    uint8_t tx = sqi->state == SQI_STATE_TX_HI ? (sqi->data[sqi->addr] >> 4)
                                               : (sqi->data[sqi->addr] & 0xf);

    stdio_printf("SQI: TX addr=0x%04x data=0x%x\n", sqi->addr, tx);

    // Top 4b is data, bottom 4b is direction.
    *sqi->txf = (tx << 4) | 1;

    if (sqi->state == SQI_STATE_TX_HI)
    {
        sqi->state = SQI_STATE_TX_LO;
    }
    else
    {
        sqi->state = SQI_STATE_TX_HI;
        sqi->addr++;
    }
}

#endif // PODI_SQI_H
