//
//  SelectionUI.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformTools
import ReformStage

struct SelectionUIRenderer : Renderer {
    let selectionUI : SelectionUI
    let stage : Stage
    
    func renderInContext(context: CGContext) {
        CGContextSetRGBFillColor(context, 0.2, 0.7, 1, 0.6)
        CGContextSetRGBStrokeColor(context, 0.2, 0.6, 0.9, 0.6)
        CGContextSetLineWidth(context, 5)
        
        switch selectionUI.state {
        case .Hide:
            break
        case .Show(let selection):
            for entity in stage.entities where selection.selected.contains(entity.id) {
                drawSegmentPath(context, path:entity.outline)
                
                CGContextDrawPath(context, CGPathDrawingMode.Stroke)
                
            }
        }

        switch selectionUI.rect {
        case .Hide:
            break
        case .Show(let min, let max):
            let rect = CGRect(x: Int(min.x), y:Int(min.y), width: Int(max.x - min.x), height: Int(max.y - min.y))
            CGContextSetLineWidth(context, 1)
            CGContextSetRGBStrokeColor(context, 0.6, 0.6, 0.6, 0.6)
            CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 0.1)

            CGContextStrokeRect(context, rect)
            CGContextFillRect(context, rect)
        }
    }
}