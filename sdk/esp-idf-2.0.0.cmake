if(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    set(ESP32_SDK_BASE ${USER_HOME}/git/esp-idf CACHE PATH "Path to the ESP32 SDK")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
    set(ESP32_SDK_BASE ${USER_HOME}/dev/projects/esp-idf CACHE PATH "Path to the ESP32 SDK")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    set(ESP32_SDK_BASE /Volumes/ESP32Toolchain/esp-idf CACHE PATH "Path to the ESP32 SDK")
else()
    message(FATAL_ERROR "Unsupported build platforom.")
endif()

if (ESP32_FLASH_SIZE MATCHES "512K")
    set(FW_ADDR_1 0x00000)
    set(FW_ADDR_2 0x40000)
elseif (ESP32_FLASH_SIZE MATCHES "1M")
    set(FW_ADDR_1 0x00000)
    set(FW_ADDR_2 0x01010)
else()
    message(FATAL_ERROR "Unsupported flash size")
endif()

file(GLOB_RECURSE SOURCES "${ESP32_SDK_BASE}/*.c")

set_target_properties(firmware PROPERTIES
        LINK_FLAGS "-L${ESP32_SDK_BASE}/components/esp32/ld \
                    -L${ESP32_SDK_BASE}/components/esp32/lib
                    -Tesp32_out.ld \
                    -Tesp32.common.ld \
                    -Tesp32.rom.ld \
                    -Tesp32.peripherals.ld")


set(COMPONENTS  app_update
                bootloader
                bootloader_support
                bt
                coap
                cxx
                driver
                esp32
                esptool_py
                ethernet
                expat
                fatfs
                freertos
                idf_test
                json
                log
                lwip
                mbedtls
                micro-ecc
                newlib
                nghttp
                nvs_flash
                openssl
                partition_table
                sdmmc
                spi_flash
                tcpip_adapter
                ulp
                vfs
                wpa_supplicant
                xtensa-debug-module)

set(INCLUDE_DIRS "")

foreach (component ${COMPONENTS})
    list (APPEND INCLUDE_DIRS ${IDF_PATH}/components/${component})
endforeach()

target_include_directories(ESP32_SDK INTERFACE ${INCLUDE_DIRS})

add_custom_target(
    firmware_binary ALL
    COMMAND ${ESP32_ESPTOOL} -bz ${ESP32_FLASH_SIZE} -eo $<TARGET_FILE:firmware> -bo firmware_${FW_ADDR_1}.bin -bs .text -bs .data -bs .rodata -bc -ec -eo $<TARGET_FILE:firmware> -es .irom0.text firmware_${FW_ADDR_2}.bin -ec
)
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "firmware_${FW_ADDR_1}.bin firmware_${FW_ADDR_2}.bin")

add_dependencies(firmware_binary firmware)

add_custom_target(flash COMMAND ${ESP32_ESPTOOL} -cp ${ESP32_ESPTOOL_COM_PORT} -cf firmware_${FW_ADDR_1}.bin -ca 0x40000 -cf firmware_${FW_ADDR_2}.bin)

add_dependencies(flash firmware_binary)
