//===----------------------------------------------------------------------===//
//
// This source file is loosly based the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//


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

let buttonGPIO:   Int32 = 5
var button:        GPIOHandler!
var knob:          ADConverter!
var knobTimer:     Timer!

let ledRedGPIO:   Int32 = 10
let ledGreenGPIO: Int32 = 11
let ledBlueGPIO:  Int32 = 12
let knobChannel = ADC_CHANNEL_0 // GPIO1
var ledStrip: LedStrip!
let ledStripLength: UInt32 = 1
let ledStripGPIO: Int32 = 8 // internal
var ledTimer: Timer!

@_cdecl("app_main")
func main() {
    
    var redOutput:     GPIOOutput// = try! .init(gpio: ledRedGPIO)
    var greenOutput: GPIOOutput// = try! .init(gpio: ledGreenGPIO)
    var blueOutput: GPIOOutput// = try! .init(gpio: ledBlueGPIO)
    
    var colorLed: RGBLed
    
    
    
    var activeChannel: ActiveChannel = .red {
        didSet { 
            turnOn(channel: activeChannel) 
        }
    }

    var currentColor: RGBColor = .init(red: 25, green: 30, blue: 5) {
        didSet { 
            colorLed.setColor(currentColor) 
            updateStrip()
        }
    }

    /* Leds */
    
    do {
        redOutput =   try GPIOOutput(gpio: ledRedGPIO)
        blueOutput =  try GPIOOutput(gpio: ledBlueGPIO)
        greenOutput = try GPIOOutput(gpio: ledGreenGPIO)
    } catch { fatalError("Leds initialization failed \(error)") }
    
    /* ColorLed */ 
    
    do {  colorLed = try RGBLed(channels: rgbLedChannels) } 
    catch {  fatalError("Led initialization failed \(error)") }
    colorLed.setColor(currentColor)
    
    /* Button */
    
    do { 
        button = try GPIOHandler(gpio: buttonGPIO) 
        {  activeChannel = activeChannel.next }
    } catch { fatalError("Button initialization failed \(error)") }
    
    /* Knob */
    
    do { knob = try ADConverter(channel: knobChannel) }
    catch { fatalError("Knob initialization failed: \(error)") }
    
    let knobTreshold: UInt64 = 1
    
    /* Knob timer */
    
    do { knobTimer = try Timer(name: "Check Potentiometer Value") 
        { let before = knob.lastRead
            let value = knob.valueInterpolated(in: 0...255)
            if abs(value - before) > knobTreshold,
               let value = UInt8(exactly: value) {
                switch activeChannel {
                case .red: 
                    currentColor.red = value
                    
                case .green:
                    currentColor.green = value
                case .blue:
                    currentColor.blue = value
                }
                
            }
        }
    } catch {
        fatalError("Knob initialization failed: \(error)")
    }   
    knobTimer.start(intervalMs: 5)
    
    
    /* LED Strip */
    do {
        ledStrip = try LedStrip(gpioNr: ledStripGPIO, 
                                  maxLeds: ledStripLength)
    } catch {
        fatalError("LED Strip initialization failed: \(error)")
    }
    turnOn(channel: activeChannel) 
     ledStrip.setPixel(index: 0, color: currentColor)
    ledStrip.refresh()
     
    //LED Timer
    
//    do {
//        ledTimer = try Timer(name: "Led Timer") {
//            led.setPixel(index: 0,
//                         color: ledIsOn ? .lightWhite : .off)
//            led.refresh()
//            ledIsOn.toggle()  // Toggle the boolean value
//        }
//    } catch {
//        print ("Led strip initialization failed: \(error)")
//    }
//    ledTimer?.start(intervalMs: 1511)
    
    func updateStrip() {
        ledStrip.setPixel(index: 0, 
                          color: currentColor.channel(activeChannel))
        ledStrip.refresh()
    }
    
    func turnOn(channel: ActiveChannel) {
        do  {
            switch activeChannel {
            case .red: 
                try redOutput.on()
                try greenOutput.off()
                try blueOutput.off()
                
            case .green:
                try redOutput.off()
                try greenOutput.on()
                try blueOutput.off()
                
            case .blue: 
                try  redOutput.off()
                try  greenOutput.off()
                try  blueOutput.on()
               
            }  
        } catch { fatalError("Error setting GPIO levels: \(error)") } 
    }
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
