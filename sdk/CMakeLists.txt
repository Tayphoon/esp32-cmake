add_library(ESP32_SDK INTERFACE)

if (NOT DEFINED ESP32_SDK_VARIANT OR ESP32_SDK_VARIANT STREQUAL "")
    message(FATAL_ERROR "ESP32_SDK_VARIANT has not been defined")
endif ()

if (NOT DEFINED ESP32_SDK_VERSION OR ESP32_SDK_VERSION STREQUAL "")
    message(FATAL_ERROR "ESP32_SDK_VERSION has not been defined")
endif()

if (ESP32_SDK_VARIANT MATCHES "esp-idf")
    include(esp-idf-${ESP32_SDK_VERSION}.cmake)
else()
    message(FATAL_ERROR "Unknown ESP32_SDK_VARIANT given.")
endif()
