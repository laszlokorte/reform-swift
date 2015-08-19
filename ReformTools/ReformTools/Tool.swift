//
//  Tool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol Tool {
    func setUp()
    
    func tearDown()
    
    func refresh()
    
    func focusChange()
    
    func process(input: Input, atPosition: Vec2d, withModifier: Modifier)
    
    func cancel()
}