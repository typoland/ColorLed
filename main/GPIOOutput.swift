//
//  GPIOOutput.swift
//  
//
//  Created by Łukasz Dziedzic on 11/04/2025.
//
class GPIOOutput {
    let gpioNumber: Int32
    
    enum Error: Swift.Error {
        case configFailed(String)
        case setLevelFailed(String)
    }
    
    init(gpio: Int32) throws (GPIOOutput.Error){
        self.gpioNumber = gpio
        
        var ioConf = gpio_config_t(
            pin_bit_mask: 1 << gpioNumber,
            mode: GPIO_MODE_OUTPUT,
            pull_up_en: GPIO_PULLUP_DISABLE,
            pull_down_en: GPIO_PULLDOWN_DISABLE,
            intr_type: GPIO_INTR_DISABLE,
            hys_ctrl_mode: GPIO_HYS_SOFT_DISABLE
        )
        
        switch runEsp({ gpio_config(&ioConf) }) {
        case .success: break
        case .failure(let error): throw .configFailed(error)
        }
    }
    
    func set(level: UInt32) throws (GPIOOutput.Error) {
        switch runEsp({ gpio_set_level(gpio_num_t(gpioNumber), level) }) {
        case .success: break
        case .failure(let error): throw .setLevelFailed(error)
            
        }
        //vTaskDelay(100 / (1000 / UInt32(configTICK_RATE_HZ)))
    }
    
    func on() throws (GPIOOutput.Error){
        try set(level: 1)
    }
    
    func off() throws(GPIOOutput.Error) {
        try set(level: 0)
    }
}
