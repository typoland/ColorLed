
#include <stdio.h>
#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"
#include "freertos/semphr.h"
#include "driver/gpio.h"
#include "sdkconfig.h"
#include "driver/ledc.h"
#include "esp_timer.h"
#include "esp_log.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_continuous.h"
#include "esp_pm.h"
#include "led_strip.h"

/*
// gpio_interrupt_bridge.h

#ifndef gpio_interrupt_bridge_h
#define gpio_interrupt_bridge_h

void configure_gpio_interrupt(void);

#endif *//* gpio_interrupt_bridge_h */

