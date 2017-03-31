set(CMAKE_SYSTEM_NAME ESP32)
set(CMAKE_SYSTEM_VERSION 1)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Platform")

set (ESP32_FLASH_SIZE "512K" CACHE STRING "Size of flash")

if(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    set(USER_HOME $ENV{HOME})
    set(HOST_EXECUTABLE_PREFIX "")
    set(ESPTOOL_EXECUTABLE_SUFFIX "")
    set(ESPTOOL_COM_PORT /dev/ttyUSB0 CACHE STRING "COM port to be used by esptool")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
    set(USER_HOME $ENV{USERPROFILE})
    set(HOST_EXECUTABLE_SUFFIX ".exe")
    set(ESPTOOL_EXECUTABLE_SUFFIX ".exe")
    set(ESPTOOL_COM_PORT COM1 CACHE STRING "COM port to be used by esptool")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    set(USER_HOME $ENV{HOME})
    set(HOST_EXECUTABLE_PREFIX "")
    set(ESPTOOL_EXECUTABLE_SUFFIX "")
    set(ESPTOOL_COM_PORT /dev/tty.SLAB_USBtoUART CACHE STRING "COM port to be used by esptool")
else()
    message(FATAL_ERROR Unsupported build platform.)
endif()

set(ESP_TOOLCHAIN_DIR /Volumes/ESP32Toolchain/xtensa-esp32-elf/bin)

file(GLOB_RECURSE ESP32_XTENSA_C_COMPILERS ${ESP_TOOLCHAIN_DIR}/xtensa-esp32-elf-gcc FOLLOW_SYMLINKS xtensa-esp32-elf-gcc${HOST_EXECUTABLE_SUFFIX})
list(GET ESP32_XTENSA_C_COMPILERS 0 ESP32_XTENSA_C_COMPILER)
file(GLOB_RECURSE ESP32_XTENSA_CXX_COMPILERS ${ESP_TOOLCHAIN_DIR}/xtensa-esp32-elf-gcc FOLLOW_SYMLINKS xtensa-esp32-elf-g++${HOST_EXECUTABLE_SUFFIX})
list(GET ESP32_XTENSA_CXX_COMPILERS 0 ESP32_XTENSA_CXX_COMPILER)
file(GLOB_RECURSE ESPTOOLS /Volumes/ESP32Toolchain/esp-idf/components/esptool/esptool FOLLOW_SYMLINKS esptool${ESPTOOL_EXECUTABLE_SUFFIX})
list(GET ESPTOOLS 0 ESPTOOL)

message("Using " ${ESP32_XTENSA_C_COMPILER} " C compiler.")
message("Using " ${ESP32_XTENSA_CXX_COMPILER} " C++ compiler.")
message("Using " ${ESPTOOL} " esptool binary.")

#Set compilers
set(CMAKE_C_COMPILER ${ESP32_XTENSA_C_COMPILER})
set(CMAKE_CXX_COMPILER ${ESP32_XTENSA_CXX_COMPILER})

# CPPFLAGS used by C preprocessor
set(CPPFLAGS "-MMD -c")

# Warnings-related flags relevant both for C and C++
set(COMMON_WARNING_FLAGS "-Wall -Werror=all \
                          -Wno-error=unused-function \
                          -Wno-error=unused-but-set-variable \
                          -Wno-error=unused-variable \
                          -Wno-error=deprecated-declarations \
                          -Wextra \
                          -Wno-unused-parameter -Wno-sign-compare")

# Flags which control code generation and dependency generation, both for C and C++
set(COMMON_FLAGS "-ffunction-sections -fdata-sections \
                  -fstrict-volatile-bitfields \
                  -mlongcalls \
                  -nostdlib \
                  -Wpointer-arith")

# Optimization flags
set(OPTIMIZATION_FLAGS "-Os -g3")

set(CMAKE_C_FLAGS "-std=gnu99 \
                   ${OPTIMIZATION_FLAGS} \
                   ${COMMON_FLAGS} \
                   ${COMMON_WARNING_FLAGS} -Wno-old-style-declaration -MMD -c")

set(CMAKE_CXX_FLAGS "-std=gnu++11 \
                     -fno-exceptions \
                     -fno-rtti \
                     ${OPTIMIZATION_FLAGS} \
                     ${COMMON_FLAGS} \
                     ${COMMON_WARNING_FLAGS} \
	                 ${CPPFLAGS}")

set(CMAKE_EXE_LINKER_FLAGS "-nostdlib -u call_user_start_cpu0 -Wl,--gc-sections -Wl,-static -Wl,--undefined=uxTopUsedPriority")

set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> -o <TARGET> -Wl,--start-group <OBJECTS> <LINK_LIBRARIES> -lc -Wl,--end-group")
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> -o <TARGET> -Wl,--start-group <OBJECTS> <LINK_LIBRARIES> -lc -Wl,--end-group")