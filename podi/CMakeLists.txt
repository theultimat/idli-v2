cmake_minimum_required(VERSION 3.13)

include(pico-sdk/pico_sdk_init.cmake)

project(podi)

pico_sdk_init()


add_executable(podi
    main.c
)

target_link_libraries(podi pico_stdlib hardware_pio)

pico_generate_pio_header(podi ${CMAKE_CURRENT_LIST_DIR}/sqi.pio)
pico_enable_stdio_usb(podi 1)
pico_add_extra_outputs(podi)
