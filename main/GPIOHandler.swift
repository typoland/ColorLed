
class GPIOHandler {
    let gpioNumber: Int32
    var handle: () -> Void
    
    enum Error: Swift.Error {
        case configFailed(String)
        case ISRServiceFailed(String)
        case ISRHandlerAddFailed(String)
    }
    
    init(gpio: Int32, 
         configuration: Config = .default, 
         handle: @escaping () -> Void) 
    throws(GPIOHandler.Error) 
    {
        self.gpioNumber = gpio
        self.handle = handle

        try configuration.set(on: gpioNumber)
        
        // Install the GPIO ISR service
        switch runEsp({gpio_install_isr_service(0)}) {
        case .success: break
        case .failure(let error): throw .ISRServiceFailed(error)
        }
       
        // Attach the interrupt handler
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        switch runEsp({
            gpio_isr_handler_add(
                gpio_num_t(gpioNumber), 
                gpio_isr_handler, 
                selfPointer)
        }) 
        {
        case .success: break
        case .failure(let error): throw .ISRHandlerAddFailed(error)
        }
    }
    
    deinit {
        gpio_isr_handler_remove(gpio_num_t(gpioNumber))
    }
    
    let gpio_isr_handler: @convention(c) (UnsafeMutableRawPointer?) -> Void = { arg in
        guard let arg = arg else { return }
        let handler = Unmanaged<GPIOHandler>
            .fromOpaque(arg)
            .takeUnretainedValue()
        handler.run()
    }
    
    func run() {
        handle()
    }
    
    struct Config {
        static var `default`: Config = .init()
        var mode          = GPIO_MODE_INPUT
        var pull_up_en    = GPIO_PULLUP_ENABLE
        var pull_down_en  = GPIO_PULLDOWN_DISABLE
        var intr_type     = GPIO_INTR_NEGEDGE
        var hys_ctrl_mode = GPIO_HYS_SOFT_DISABLE
        
        func set(on pinNr: Int32) throws (GPIOHandler.Error) {
            var io_conf = gpio_config_t(
                pin_bit_mask: 1 << pinNr,
                mode: mode,
                pull_up_en: pull_up_en,
                pull_down_en: pull_down_en,
                intr_type: intr_type,
                hys_ctrl_mode: hys_ctrl_mode
            )
            switch runEsp ({  gpio_config(&io_conf) } ) {
            case .success: break
            case .failure(let error): throw .configFailed(error)
            }
        }
    }
}



