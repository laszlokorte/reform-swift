//
//  Color.swift
//  ReformGraphics
//
//  Created by Laszlo Korte on 16.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Color {
    let red : Int8
    let green : Int8
    let blue: Int8
    let alpha : Int8
    
    init(r:Int8, g:Int8, b:Int8, a:Int8) {
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
}