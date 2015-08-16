//
//  Color.swift
//  ReformGraphics
//
//  Created by Laszlo Korte on 16.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Color {
    let red : UInt8
    let green : UInt8
    let blue: UInt8
    let alpha : UInt8
    
    public init(r:UInt8, g:UInt8, b:UInt8, a:UInt8) {
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
}