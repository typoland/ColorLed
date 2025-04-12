
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

struct RGBColor {
    var red, green, blue: UInt8
}

extension RGBColor {
    func channel(_ channel: ActiveChannel) -> RGBColor {
        switch channel {
        case .red:   return RGBColor(red: red, green: 0,     blue: 0   ) 
        case .green: return RGBColor(red: 0,   green: green, blue: 0   ) 
        case .blue:  return RGBColor(red: 0,   green: 0,     blue: blue)
        }
    }
}

extension RGBColor {
    static var white = RGBColor(red: 255, green: 255, blue: 255)
    static var off =   RGBColor(red: 0, green: 0, blue: 0)
    static var lightWhite = RGBColor(red: 16, green: 16, blue: 16)
    static var lightRandom: RGBColor {
        RGBColor(
            red:   .random(in: 0...16), 
            green: .random(in: 0...16), 
            blue:  .random(in: 0...16))
    }
    
}
