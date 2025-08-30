#include <stdint.h>

#include "hardware/gpio.h"
#include "hardware/pio.h"
#include "pico/stdio.h"

#include "sqi.h"


// GPIO pins to use for communication with idli.
#define IDLI_MEM_LO_SIO_0   (2)
#define IDLI_MEM_LO_SIO_1   (3)
#define IDLI_MEM_LO_SIO_2   (4)
#define IDLI_MEM_LO_SIO_3   (5)
#define IDLI_MEM_LO_SCK     (6)
#define IDLI_MEM_LO_CS      (7)

#define IDLI_MEM_HI_SIO_0   (8)
#define IDLI_MEM_HI_SIO_1   (9)
#define IDLI_MEM_HI_SIO_2   (10)
#define IDLI_MEM_HI_SIO_3   (11)
#define IDLI_MEM_HI_SCK     (12)
#define IDLI_MEM_HI_CS      (13)

#define IDLI_RST_N          (16)

#define IDLI_UART_TX        (20)
#define IDLI_UART_RX        (21)


// Commands supported by the device.
typedef enum
{
    CMD_PING,
    CMD_FLASH,
    CMD_RUN,

    CMD__NUM
} cmd_t;


// Low and high memories for idli to access via SQI.
static sqi_t mem_lo;
static sqi_t mem_hi;


// Strings for printing commands back out to host for debug.
static const char* CMD_STR[CMD__NUM] =
{
    "PING",
    "FLASH",
    "RUN",
};


// Ping command just prints out a simple message for testing the serial
// connection to the host.
static void cmd_ping(void)
{
    stdio_puts("Ping!");
}

// Flash is used to download a new binary into the two memories. This command
// takes a payload of the following format:
//  - u16   Number of bytes to write to each memory, little endian.
//  - u8*n  Bytes to write into low memory.
//  - u8*n  Bytes to write into high memory.
static void cmd_flash(void)
{
    // Read in number of bytes to write.
    uint16_t n = 0;

    for (int i = 0; i < 2; ++i)
    {
        const int data = stdio_getchar_timeout_us(~0u);
        if (data == PICO_ERROR_TIMEOUT)
        {
            stdio_puts("ERROR: Timeout waiting for flash payload size.");
            return;
        }

        n |= (data & 0xff) << (i * 8);
    }

    stdio_printf("Flashing %u bytes to each memory.\n", n);

    // Read bytes into each of the memories.
    sqi_t *mems[] = { &mem_lo, &mem_hi };

    for (int i = 0; i < 2; ++i)
    {
        for (uint16_t b = 0; b < n; ++b)
        {
            const int data = stdio_getchar_timeout_us(~0u);
            if (data == PICO_ERROR_TIMEOUT)
            {
                stdio_printf("ERROR: Memory %d: byte %u/%u timed out.", i, b, n);
                return;
            }

            mems[i]->data[b] = data & 0xff;
        }
    }

    stdio_puts("Flashing complete.");
}

// Run whatever is currently programmed into the memories by coming out of
// reset and servicing memory accesses.
static void cmd_run(void)
{
    gpio_put(IDLI_RST_N, 1);

    // TODO Need an end condition! Wait for UART end of test?
    while (1)
    {
        sqi_tick(&mem_hi);
        sqi_tick(&mem_lo);
    }
}


// Function pointers for each of the commands.
static void (*CMD_FUNCS[CMD__NUM])(void) =
{
    cmd_ping,
    cmd_flash,
    cmd_run,
};


int main(void)
{
    // Receive commands via stdin from host.
    stdio_init_all();

    // Configure GPIO pins excluding those controlled by PIO.
    gpio_init(IDLI_RST_N);
    gpio_init(IDLI_MEM_LO_CS);
    gpio_init(IDLI_MEM_HI_CS);

    gpio_set_dir(IDLI_RST_N, GPIO_OUT);
    gpio_set_dir(IDLI_MEM_LO_CS, GPIO_IN);
    gpio_set_dir(IDLI_MEM_HI_CS, GPIO_IN);

    gpio_pull_up(IDLI_MEM_LO_CS);
    gpio_pull_up(IDLI_MEM_HI_CS);

    // TODO Init UART.

    // LED indicates status of the device. ON indicates waiting for a command
    // from the host, OFF indicates a command is in progress.
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);

    // Hold idli in reset until a command wakes it up.
    gpio_put(IDLI_RST_N, 0);

    // Initialise the PIO state machines for running the SQI interfaces.
    sqi_init(&mem_lo, pio0, IDLI_MEM_LO_SIO_0, IDLI_MEM_LO_CS);
    sqi_init(&mem_hi, pio1, IDLI_MEM_HI_SIO_0, IDLI_MEM_HI_CS);

    // Enter the main command loop.
    while (1)
    {
        // Wait for the next command to arrive and indicate status via LED.
        gpio_put(PICO_DEFAULT_LED_PIN, 1);

        int cmd;
        do
        {
            cmd = stdio_getchar_timeout_us(~0u);
        } while (cmd == PICO_ERROR_TIMEOUT);

        // We received something so turn off the LED.
        gpio_put(PICO_DEFAULT_LED_PIN, 0);

        // Check the command is valid, printing an error code if not.
        if (cmd >= CMD__NUM)
        {
            stdio_printf("ERROR: Invalid command: 0x%02x\n", cmd);
            continue;
        }

        // Run the command.
        stdio_printf("Run command: %s (0x%02x)\n", CMD_STR[cmd], cmd);
        CMD_FUNCS[cmd]();
        stdio_puts("=== DONE ===");
    }

    return 0;
}
