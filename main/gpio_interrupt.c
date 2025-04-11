//
//  interrupt.c
//  
//
//  Created by Łukasz Dziedzic on 10/04/2025.
//
/*
#include "driver/gpio.h"
#include "esp_attr.h"  // For IRAM_ATTR
#include "esp_log.h"

#define BUTTON_GPIO GPIO_NUM_5

static void IRAM_ATTR gpio_isr_handler(void* arg) {
    // Call the Swift function
    extern void buttonPressed(void);
    buttonPressed();
}

void configure_gpio_interrupt() {
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << GPIO_NUM_5),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_ENABLE,
        .intr_type = GPIO_INTR_NEGEDGE, // Interrupt on falling edge
    };
    gpio_config(&io_conf);
    
    gpio_install_isr_service(0);
    gpio_isr_handler_add(GPIO_NUM_5, gpio_isr_handler, NULL);
}
*/

