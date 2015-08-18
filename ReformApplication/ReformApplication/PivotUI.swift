//
//  PivotUI.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformTools
import ReformStage

struct PivotUIRenderer : Renderer {
    let pivotUI : PivotUI
    
    func renderInContext(context: CGContext) {
        CGContextSetRGBFillColor(context, 0.23, 0.85, 0.3, 1)
        CGContextSetRGBStrokeColor(context, 0.18, 0.5, 0.24, 1)
        CGContextSetLineWidth(context, 2)
        let dotSize : Double = 12
        
        switch pivotUI.state {
        case .Hide:
            return
        case .Show(let point):
            drawDotAt(context, position: point.position, size: dotSize*1.5)
            
            break
        }
    }
}
