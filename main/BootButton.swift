//
//  Button.swift
//  

/*
struct Button<T>: ~Copyable {
    var gpio: UnsafePointer<gpio_dt_spec>
    var handle: GpioCallbackHandler?
    var pin_cb_data: UnsafeMutablePointer<ExtendedCallback<T>>
    
    init(gpio: UnsafePointer<gpio_dt_spec>, context: T, handle: GpioCallbackHandler?) {
        if (!gpio_is_ready_dt(gpio)) {
            fatalError("Button init error, GPIO not ready")
        }
        
        self.gpio = gpio
        self.pin_cb_data = UnsafeMutablePointer<ExtendedCallback<T>>.allocate(capacity: 1)
        
        self.pin_cb_data.pointee.callback = gpio_callback()
        self.pin_cb_data.pointee.context = context
        self.handle = handle
        
        var ret = gpio_pin_configure_dt(self.gpio, GPIO_INPUT)
        if ret < 0 {
            fatalError("Button init error, configure pin failed")
        }
        
        ret = gpio_pin_interrupt_configure_dt(gpio, GpioInterrupts.edgeToActive)
        if ret < 0 {
            fatalError("Button init error, configure interrupt failed")
        }
        
        gpio_init_callback(&self.pin_cb_data.pointee.callback, self.handle, bit(gpio.pointee.pin))
        
        ret = gpio_add_callback(self.gpio.pointee.port, &self.pin_cb_data.pointee.callback)
        
        if ret < 0 {
            fatalError("Button init error, configure calback failed")
        }
    }
    
    deinit {
        gpio_remove_callback(gpio.pointee.port, &pin_cb_data.pointee.callback)
        pin_cb_data.deallocate()
    }
}

*/
struct Button  {
    let gpioNumber: Int32 //
    var handle: () -> Void = {}
    
    enum Error: Swift.Error {
        case gpioConfigFailed
    }
    
    init(gpio: Int32, handle: @escaping () -> Void) throws(Button.Error) {
        // Configure GPIO9 as an input
        self.gpioNumber = gpio
        self.handle = handle
        var io_conf = gpio_config_t(
            pin_bit_mask: 1 << gpioNumber,
            mode:          GPIO_MODE_INPUT,
            pull_up_en:    GPIO_PULLUP_ENABLE,
            pull_down_en:  GPIO_PULLDOWN_DISABLE,
            intr_type:     GPIO_INTR_LOW_LEVEL,//GPIO_INTR_NEGEDGE, // Interrupt on falling edge
            hys_ctrl_mode: GPIO_HYS_SOFT_DISABLE // Enable hysteresis
        )
        guard gpio_config(&io_conf) == ESP_OK 
        else { throw .gpioConfigFailed }
        
        // Install the GPIO ISR service
//        guard gpio_install_isr_service(ESP_INTR_FLAG_LEVEL3) == ESP_OK
//        else { throw .installIsrServiceFailed }
        
//        guard gpio_isr_handler_add(gpio_num_t(gpioNumber), 
//                                   gpio_isr_handler, 
//                                   Unmanaged.passUnretained(self).toOpaque()) == ESP_OK 
//        else { throw .gpioIsrHandlerAddFailed }
        
        print ("button initilized withot error")
    }
}

