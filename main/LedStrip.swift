

struct LedStrip: OnOff {
    enum Error: Swift.Error {
        case cannotOpenDevice(String)
        case cannotCreateHandle
    }
    
    private let handle: led_strip_handle_t
    
    init(gpioNr: Int32, maxLeds: UInt32)//, config: Config = .default )
    throws ( LedStrip.Error) {
        var handle = led_strip_handle_t(bitPattern: 0)
        var stripConfig = led_strip_config_t(
            strip_gpio_num: gpioNr,
            max_leds: maxLeds,
            led_pixel_format: LED_PIXEL_FORMAT_GRB,
            led_model: LED_MODEL_WS2812,
            flags: .init(invert_out: 0)
        )
        var spiConfig = led_strip_spi_config_t(
            clk_src: SPI_CLK_SRC_DEFAULT,
            spi_bus: SPI2_HOST,
            flags: .init(with_dma: 1)
        )
        switch runEsp({led_strip_new_spi_device(&stripConfig,
                                                &spiConfig,
                                                &handle)}) {
            case .failure(let msg): throw Error.cannotOpenDevice(msg)
            case .success:
            guard let handle = handle
                    else { throw .cannotCreateHandle }
            self.handle = handle
        }
        //self.handle = try config.getHandle(on: gpioNr, maxLeds: maxLeds)
    }
    func turnOn() {
        setPixel(index: 0, color: .white)
        refresh()
    }
    func turnOff() {
        setPixel(index: 0, color: .off)
        refresh()
    }
    func setPower(_ power: Bool) {
        power ? turnOn() : turnOff()
    }

    func setPixel(index: Int, color: RGBColor) {
        led_strip_set_pixel(
            handle, 
            UInt32(index), 
            UInt32(color.red), 
            UInt32(color.green), 
            UInt32(color.blue))
    }
    
    func refresh() { led_strip_refresh(handle) }
    func clear() { led_strip_clear(handle) }
    /*
    struct Config {
//        var strip_gpio_num   = Int32gpioPin,
//        var max_leds         = UInt32(maxLeds),
        static var `default`: Config  { Config() }
        
        var pixelFormat    = LED_PIXEL_FORMAT_GRB
        var model          = LED_MODEL_WS2812
        //var flags: led_strip_config_t.flags = 
        
        var SPIClockSource = SPI_CLK_SRC_DEFAULT
        var SPIBus         = SPI2_HOST
        //var SPIFlags:led_strip_spi_config_t.flags = 
        
        func getHandle(on gpioNr: Int32, maxLeds: UInt32) 
        throws (LedStrip.Error) -> led_strip_handle_t {
            var handle = led_strip_handle_t(bitPattern: 0)
            
            var stripConfig = led_strip_config_t(
                strip_gpio_num: gpioNr,
                max_leds: maxLeds,
                led_pixel_format: pixelFormat,
                led_model: model,
                flags: .init(invert_out: 0)
            )
            var spiConfig = led_strip_spi_config_t(
                clk_src: SPIClockSource,
                spi_bus: SPIBus,
                flags: .init(with_dma: 1)
            )
            switch runEsp( {led_strip_new_spi_device(&stripConfig,
                                                     &spiConfig,
                                                     &handle)}) {
            case .success:
                if let handle = handle {
                    return handle
                } else {throw .cannotCreateHandle}
            case .failure(let err):
                throw .cannotOpenDevice(err)
            } 
        }
    }
     */
}


