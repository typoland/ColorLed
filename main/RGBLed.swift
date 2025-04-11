//
//  ColorLed.swift
//  
//
//  Created by Łukasz Dziedzic on 09/04/2025.
//


struct RGBLed {
    enum Error: Swift.Error {
        case ledcConfigError(String)
        case channelConfigurationFailed(String)
    }

    let channels: Channels
    let setup: Setup
    
    init(channels: RGBLed.Channels, 
         setup: RGBLed.Setup = RGBLed.Setup()) 
    throws(RGBLed.Error) {
        
        self.channels = channels
        self.setup = setup
        try setup.set()
        
        // Configure the LEDC channels
        try channels.red.set(with: setup)
        try channels.green.set(with: setup)
        try channels.blue.set(with: setup)
    }
    
    func setColor(red: UInt8, green: UInt8, blue: UInt8) {
        setDuty(channel: channels.red.ledcChannel, duty: red)
        setDuty(channel: channels.green.ledcChannel, duty: green)
        setDuty(channel: channels.blue.ledcChannel, duty: blue)
    }
    func setColor(_ color: RGBColor) {
        setColor(red: color.red, green: color.green, blue: color.blue)
    }
    
    private func setDuty(channel: ledc_channel_t, duty: UInt8) {
        let dutyValue = UInt32(duty) * ((1 << setup.ledcDutyResolution.rawValue) - 1) / 255
        ledc_set_duty(setup.ledcMode, channel, dutyValue)
        ledc_update_duty(setup.ledcMode, channel)
    }
    
    struct Channels {
        let red:   Settings
        let green: Settings
        let blue:  Settings
        
        struct Settings {
            let ledcChannel: ledc_channel_t
            let ledcGPIO: Int32
            
            fileprivate func set(with setup: RGBLed.Setup) throws( RGBLed.Error) {
                var ledcChannelConfig = ledc_channel_config_t(
                    gpio_num:   ledcGPIO,
                    speed_mode: setup.ledcMode,
                    channel:    ledcChannel,
                    intr_type:  LEDC_INTR_FADE_END,//LEDC_INTR_DISABLE,
                    timer_sel:  setup.ledcTimer,
                    duty:  0,
                    hpoint: 0,
                    flags: .init()
                )
                switch runEsp ({ledc_channel_config(&ledcChannelConfig)}) {
                case .success: break
                case .failure(let s): 
                    throw Error.channelConfigurationFailed(s)
                }
            }
        } 
    }
    
    struct Setup {
        let ledcTimer = LEDC_TIMER_1
        let ledcMode =  LEDC_LOW_SPEED_MODE
        let ledcDutyResolution = LEDC_TIMER_13_BIT // resolution to 13 bits
        let ledcFrequency: UInt32 = 5_000 
        
        func set() throws (RGBLed.Error) {
            var ledcTimerConfig = ledc_timer_config_t(
                speed_mode:      ledcMode,
                duty_resolution: ledcDutyResolution,
                timer_num:       ledcTimer,
                freq_hz:         ledcFrequency,
                clk_cfg:         LEDC_AUTO_CLK,
                deconfigure: false
            )
            switch runEsp ({ ledc_timer_config(&ledcTimerConfig) }) {
            case .success: break
            case .failure(let s): throw Error.ledcConfigError(s)
            }
        }
    }
}
