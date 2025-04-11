//
//  ProtocolOnOff.swift
//  
//
//  Created by Łukasz Dziedzic on 08/04/2025.
//

protocol OnOff {
    init(gpio: Int)
    func turnOn()
    func turnOff()
    func setPower(_ power: Bool)
}
