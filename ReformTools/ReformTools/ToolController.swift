//
//  ToolController.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public typealias ChangeNotifier = () -> ()

public class ToolController {
    public var currentTool : Tool = NullTool() {
        willSet {
            currentTool.process(.Cancel, withModifier: [])
            currentTool.tearDown()
        }
        
        didSet {
            currentTool.setUp()
        }
    }
    
    public init() {
    
    }
    
    func process(input: Input, withModifier modifier: Modifier) {
        currentTool.process(input, withModifier: modifier)
    }
}