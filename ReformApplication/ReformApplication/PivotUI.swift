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
        
        CGContextSetRGBFillColor(context, 0.9, 0.3, 0.8, 1)
        CGContextSetRGBStrokeColor(context, 0.8, 0.2, 0.7, 1)
        CGContextSetLineWidth(context, 1)
        let dotSize : Double = 4
        
        switch pivotUI.state {
        case .Hide:
            return
        case .Show(let point):
            drawDotAt(context, position: point.position, size: dotSize*1.5)
            CGContextDrawPath(context, .FillStroke)
            break
        }
        
    }
}
