
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
    
    func set(_ level: Bool) throws (GPIOOutput.Error) {
        switch runEsp({ gpio_set_level(gpio_num_t(gpioNumber), level ? 1 : 0) }) {
        case .success: break
        case .failure(let error): throw .setLevelFailed(error)
        }
    }
    
    func on() throws (GPIOOutput.Error){
        try set(true)
    }
    
    func off() throws(GPIOOutput.Error) {
        try set(false)
    }
}
