//
//  Created by Łukasz Dziedzic on 05/04/2025.
//


struct ADConverter {
    
    enum Error: Swift.Error {
        case failedToCreateHandler
        case failedToConfigureChannel(String)
    }
    
    private var handle: adc_oneshot_unit_handle_t
    let channel: adc_channel_t
    var maxRead: Int32 = 3380
    var minRead: Int32 = 0
    
    private(set) var lastRead: Int32 = 0
    
    init (channel: adc_channel_t, 
          configuration: ChannelConfig = .default,
          unitConfig:    UnitConfig    = .default) 
    throws (ADConverter.Error) 
    {
        var handle = adc_oneshot_unit_handle_t(bitPattern: 0)
        unitConfig.set(handle: &handle)
        guard  handle != nil else {
            throw .failedToCreateHandler
        }
        self.handle = handle!
        try configuration.set(handle: &self.handle, on: channel)
        self.channel = channel
    }
    
    var value: Int32 {
        var _value: Int32 = 0
        adc_oneshot_read(handle, channel, &_value)
        return _value
    }
    
    mutating func valueInterpolated(in range: ClosedRange<Int32>) -> Int32 {
        //    value.interpolated(from: minRead...maxRead, to: range)
        let potentiometerRangeUpperBound = maxRead-minRead
        let scaled = (value-minRead)*(range.upperBound-range.lowerBound)
        / Int32(potentiometerRangeUpperBound)
        + range.lowerBound
        lastRead = scaled
        return scaled
    }
        
    struct ChannelConfig {
        var ADCAttenuation          = ADC_ATTEN_DB_12 //0, 2_5, 6, 12
        var ADCConversionResultBits = ADC_BITWIDTH_DEFAULT //DEFAULT 9, 10, 11, 12, 13 
        static var `default`: ChannelConfig = .init()
        
        func set(handle: inout adc_oneshot_unit_handle_t, 
                       on channel: adc_channel_t) 
        throws (ADConverter.Error) 
        {
            var chan_cfg = adc_oneshot_chan_cfg_t(
                atten:    ADCAttenuation, 
                bitwidth: ADCConversionResultBits 
            )
            switch runEsp({adc_oneshot_config_channel(handle, channel, &chan_cfg)}) {
            case .success: break
            case .failure(let s): throw .failedToConfigureChannel(s) 
            }
        }
    }
    
    struct UnitConfig {
        var unitID      = ADC_UNIT_1
        var clockSource = ADC_DIGI_CLK_SRC_DEFAULT
        var ulpMode     = ADC_ULP_MODE_DISABLE
        static var `default`: UnitConfig = .init()
        
        func set(handle: inout adc_oneshot_unit_handle_t?) {
            var unit_cfg = adc_oneshot_unit_init_cfg_t (
                unit_id:  unitID,
                clk_src:  clockSource,
                ulp_mode: ulpMode
            )
            adc_oneshot_new_unit(&unit_cfg, &handle)
        }
    }
}
