//
//  ToolController.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public class ToolController {
    public var currentTool : Tool = NullTool() {
        willSet {
            currentTool.process(.Cancel, withModifiers: [])
            currentTool.tearDown()
        }
        
        didSet {
            currentTool.setUp()
        }
    }
    
    public init() {
    
    }
    
    func process(input: Input, withModifiers modifiers: [Modifier]) {
        currentTool.process(input, withModifiers: modifiers)
    }
}