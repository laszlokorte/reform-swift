//
//  MaskUIRenderer.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 30.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformStage
import ReformTools


struct MaskUIRenderer : Renderer {
    let maskUI : MaskUI

    func renderInContext(context: CGContext) {

        if case .Clip(let x, let y, let width, let height) = maskUI.state {
            CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1)
            CGContextFillRect(context, CGContextGetClipBoundingBox(context))

            CGContextClipToRect(context, CGRect(x: x, y: y, width: width, height: height))
        }
        
    }
}