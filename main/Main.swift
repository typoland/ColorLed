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




let buttonGPIO:   Int32 = 5
var button:        GPIOHandler!

var knob:          ADConverter!
var knobTimer:     Timer!
let knobChannel = ADC_CHANNEL_0 // GPIO1
let knobTreshold: UInt64 = 2

let ledRedGPIO:   Int32 = 10
let ledGreenGPIO: Int32 = 12
let ledBlueGPIO:  Int32 = 11
var redLED:    GPIOOutput!// = try! .init(gpio: ledRedGPIO)
var greenLED:  GPIOOutput!// = try! .init(gpio: ledGreenGPIO)
var blueLED:   GPIOOutput!// = try! .init(gpio: ledBlueGPIO)

var colorLed: RGBLed!
let rgbLedChannels = RGBLed.Channels(
    red: RGBLed.Channels.Settings(
        ledcChannel: LEDC_CHANNEL_3, 
        ledcGPIO: 22),
    green:RGBLed.Channels.Settings(
        ledcChannel: LEDC_CHANNEL_4, 
        ledcGPIO: 2),
    blue: RGBLed.Channels.Settings(
        ledcChannel: LEDC_CHANNEL_5, 
        ledcGPIO: 3),
)

var ledStrip: LedStrip!
let ledStripLength: UInt32 = 1
let ledStripGPIO: Int32 = 8 // internal

var ledTimer: Timer!

let configTICK_RATE_HZ: UInt32 = 1000 // Example value; use your actual tick rate
let delayInMilliseconds: UInt32 = 4 // Desired delay in ms
let loopDelay = (delayInMilliseconds * configTICK_RATE_HZ) / 1000


@_cdecl("app_main")
func main() {
    enum Actions {
        case none
        case updateCurrentColorChannel(UInt8)
        case setActiveChannel(ActiveChannel)
        var name: String {
            switch self {
            case .none: return "none"
            case .updateCurrentColorChannel(let value): return "updateCurrentColorChannel(\(value))"
            case .setActiveChannel(let value): return "setActiveChannel(\(value))"
            }
        }
    }
    var currentAction: Actions = .none {
        didSet { 
            switch currentAction {
            case .updateCurrentColorChannel(let value):
                switch activeChannel {
                case .red: 
                    currentColor.red = value
                case .green:
                    currentColor.green = value
                case .blue:
                    currentColor.blue = value
                }
                updateStrip()
                
            case .setActiveChannel(let channel) :
                activeChannel = channel
                turnOnOneLed(on: activeChannel)
                //                updateStrip()
            case .none:
                break
            }
            //            print ("goes \(currentAction.name)")
            //            vTaskDelay(loopDelay)
            currentAction = .none
        }
    }

    var activeChannel: ActiveChannel = .red 

    var currentColor: RGBColor = .init(red: 25, green: 30, blue: 5) 

    /* 3 color Leds */
    
    do {
        redLED =   try GPIOOutput(gpio: ledRedGPIO)
        blueLED =  try GPIOOutput(gpio: ledBlueGPIO)
        greenLED = try GPIOOutput(gpio: ledGreenGPIO)
    } catch { fatalError("Leds initialization failed \(error)") }
    
    /* ColorLed */ 
    do { colorLed = try RGBLed(channels: rgbLedChannels) 
    } catch {  fatalError("Led initialization failed \(error)") }
    colorLed.setColor(currentColor)
    
    /* Button */
    do { 
        button = try GPIOHandler(gpio: buttonGPIO) 
        {  currentAction = .setActiveChannel(activeChannel.next) }
    } catch { fatalError("Button initialization failed \(error)") }
    
    /* Knob */
    do { knob = try ADConverter(channel: knobChannel) 
    } catch { fatalError("Knob initialization failed: \(error)") }
    
    
    /* Knob timer */
    do { knobTimer = try Timer(name: "Check Potentiometer Value") 
        { let before = knob.lastRead
            let value = knob.valueInterpolated(in: 0...255)
            if abs(value - before) > knobTreshold,
               let value = UInt8(exactly: value) {
                //print ("set value \(value)")
                currentAction = .updateCurrentColorChannel(value)
            }
        }
    } catch { fatalError("Knob initialization failed: \(error)") }   
    

    /* LED Strip */
    do { ledStrip = try LedStrip(gpioNr: ledStripGPIO, 
                                 maxLeds: ledStripLength) 
    } catch { fatalError("LED Strip initialization failed: \(error)") }
    
    
    turnOnOneLed(on: activeChannel) 
    updateStrip()
    
    knobTimer.start(intervalMs: 25) 
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
    
//    xTaskCreate(mainLoop, "Loop", 1024 * 4, nil, 0, nil)
//    while true {
//        print("loop")
//        
//       
//    }
    
    func updateStrip() {
        
        colorLed.setColor(currentColor.channel(activeChannel))
        ledStrip.setPixel(index: 0, color: currentColor)
        
        ledStrip.refresh()
        print("RGB R:\(currentColor.red), G:\(currentColor.green), B:\(currentColor.blue)")
        let c = currentColor.channel(activeChannel)
        
        print("CHN R:\(c.red), G:\(c.green), B:\(c.blue)")
    }
    
    func turnOnOneLed(on channel: ActiveChannel) {
        do  {
            switch activeChannel {
            case .red: 
                try redLED.on()
                try greenLED.off()
                try blueLED.off()
                
            case .green:
                try redLED.off()
                try greenLED.on()
                try blueLED.off()
                
            case .blue: 
                try  redLED.off()
                try  greenLED.off()
                try  blueLED.on()
               
            }  
        } catch { fatalError("Error setting GPIO levels: \(error)") } 
    }
}

