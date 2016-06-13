//
//  PreviewTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics
import ReformStage

public final class PreviewTool : Tool {

    private let maskUI : MaskUI
    private let stage : Stage
    
    public init(stage: Stage, maskUI: MaskUI) {
        self.stage = stage
        self.maskUI = maskUI
    }
    
    public func setUp() {
        let size = stage.size
        maskUI.state = .clip(x:0, y:0,width: size.x, height: size.y)
    }

    public func tearDown() {
        maskUI.state = .disabled
    }
    
    public func refresh() {
        let size = stage.size
        maskUI.state = .clip(x:0, y:0,width: size.x, height: size.y)
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
    }
    
    public func process(_ input: Input, atPosition: Vec2d, withModifier: Modifier) {
    }
}
