//
//  RGBColor.swift
//  
//
//  Created by Łukasz Dziedzic on 10/04/2025.
//

struct RGBColor {
    static var white = RGBColor(red: 255, green: 255, blue: 255)
    static var lightWhite = RGBColor(red: 16, green: 16, blue: 16)
    static var lightRandom: RGBColor {
        RGBColor(
            red: .random(in: 0...16), 
            green: .random(in: 0...16), 
            blue: .random(in: 0...16))
    }
    static var off = RGBColor(red: 0, green: 0, blue: 0)
    
    var red, green, blue: UInt8
}
