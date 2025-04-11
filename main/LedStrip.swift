/*

struct LedStrip: OnOff {
    enum Error: Swift.Error {
        case cantSetPower
    }
    
    private let handle: led_strip_handle_t
    init(gpio: Int) {
        self = .init(gpioPin: gpio, maxLeds: 1)
    }
    init(gpioPin: Int, maxLeds: Int) {
        var handle = led_strip_handle_t(bitPattern: 0)
        var stripConfig = led_strip_config_t(
            strip_gpio_num: Int32(gpioPin),
            max_leds: UInt32(maxLeds),
            led_pixel_format: LED_PIXEL_FORMAT_GRB,
            led_model: LED_MODEL_WS2812,
            flags: .init(invert_out: 0)
        )
        var spiConfig = led_strip_spi_config_t(
            clk_src: SPI_CLK_SRC_DEFAULT,
            spi_bus: SPI2_HOST,
            flags: .init(with_dma: 1)
        )
        guard led_strip_new_spi_device(&stripConfig,
                                       &spiConfig,
                                       &handle) == ESP_OK,
              let handle = handle
        else { fatalError("cannot configure spi device") }
        
        self.handle = handle
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
    
    
    
    func setPixel(index: Int, color: Color) {
        led_strip_set_pixel(
            handle, 
            UInt32(index), 
            UInt32(color.r), 
            UInt32(color.g), 
            UInt32(color.b))
    }
    
    func refresh() { led_strip_refresh(handle) }
    func clear() { led_strip_clear(handle) }
}

*/
