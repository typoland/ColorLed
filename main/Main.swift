//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// The code will blink an LED on GPIO8. To change the pin, modify Led(gpioPin: 8)

//var ledTimer: Timer?



var colorLed: RGBLed?

let rgbLedChannels = RGBLed.Channels(
    red: RGBLed.Channels.Settings(
        ledcChannel: LEDC_CHANNEL_3, 
        ledcGPIO: 22),
    green:RGBLed.Channels.Settings(
        ledcChannel: LEDC_CHANNEL_4, 
        ledcGPIO: 23),
    blue: RGBLed.Channels.Settings(
        ledcChannel: LEDC_CHANNEL_5, 
        ledcGPIO: 24),
)

var button: GPIOHandler?
let buttonGPIO: Int32 = 5

let potentiometerChannel = ADC_CHANNEL_0
var potentiometer: ADConverter = try! ADConverter(channel: ADC_CHANNEL_0)
var potentiometerTimer: Timer?


@_cdecl("app_main")
func main() {
    enum ActiveChannel: String {
        case red
        case green
        case blue
        var next: ActiveChannel {
            switch self {
            case .red: return .green
            case .green: return .blue
            case .blue: return .red
            }
        }
    }

    

    
    //var ledIsOn: Bool = true
    
    var activeChannel: ActiveChannel = .red
    var currentColor: RGBColor = .init(red: 10, green: 10, blue: 10)
    //LED
   /*
    print ("start app")
    let led = LedStrip(gpioPin: 8, maxLeds: 1)
    
    */
    //LED Timer
    /*
    do {
        ledTimer = try Timer(name: "Led Timer") {
            led.setPixel(index: 0,
                         color: ledIsOn ? .lightWhite : .off)
            led.refresh()
            ledIsOn.toggle()  // Toggle the boolean value
        }
    } catch {
        print ("Led strip initialization failed: \(error)")
    }
     */
    //ZIGBEE
    /*
     print("🚀 Zigbee app starting...")
     
     var platformCfg = esp_zb_platform_config_t()
     esp_zb_platform_config(&platformCfg)
     
     var zbCfg = esp_zb_cfg_t()
     zbCfg.esp_zb_role = ESP_ZB_DEVICE_TYPE_ROUTER
     esp_zb_init(&zbCfg)
     
     // Start Zigbee task as a FreeRTOS thread
     _ = xTaskCreate(zigbeeTask, "ZB Task", 4096, nil, 5, nil)
     
     */
    
    //ColorLed 
    
    do {  colorLed = try RGBLed(channels: rgbLedChannels) } 
    catch {  print("Led initialization failed \(error)") }
    colorLed?.setColor(currentColor)
  
    do { button = try GPIOHandler(gpio: buttonGPIO) 
        { activeChannel = activeChannel.next }
    } catch {  print("Button initialization failed \(error)") }


    
    //Potentiometer
    
    let potentiometerTreshold: UInt64 = 1
    
    do { potentiometerTimer = try Timer(name: "Check Potentiometer Value") 
        { let before = potentiometer.lastRead
            let value = potentiometer.valueInterpolated(in: 0...255)
            if abs(value - before) > potentiometerTreshold,
               let value = UInt8(exactly: value) {
                switch activeChannel {
                case .red: 
                    currentColor.red = value
                case .green:
                    currentColor.green = value
                case .blue:
                    currentColor.blue = value
                }
                colorLed?.setColor(currentColor)
            }
        }
    } catch {
        print("Potentialmeter initialization failed: \(error)")
    }

    //ledTimer?.start(intervalMs: 1511)
    potentiometerTimer?.start(intervalMs: 50)
    
    print ("initialization complete")
}

public enum ESPError {
    case failure(String)
    case success
}

func runEsp(_ command: () -> esp_err_t) -> ESPError {
    let err = command()
    guard err == ESP_OK else {
        if let s = esp_err_to_name(err) {
            return .failure("\(s)")
        } else { return .failure("Unknown error")}
    }
    return .success
}
