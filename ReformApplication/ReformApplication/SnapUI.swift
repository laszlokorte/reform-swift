//
//  SnapUI.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformTools
import ReformStage


struct SnapUIRenderer : Renderer {
    let snapUI : SnapUI
    let stage : Stage
    
    func renderInContext(context: CGContext) {
        let dotSize : Double = 7
        
        
        switch snapUI.state {
        case .Hide:
            return
        case .Show(let points):
            
            CGContextSetRGBFillColor(context, 1, 0.8, 0.2, 1)
            CGContextSetRGBStrokeColor(context, 0.8, 0.5, 0.1, 1)
            CGContextSetLineWidth(context, 1)
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            CGContextDrawPath(context, .FillStroke)
        case .Active(let active, let points):
            CGContextSetLineWidth(context, 3)
            CGContextSetRGBStrokeColor(context, 0.9, 0.7, 0.2, 1)

            for entity in stage.entities where active.belongsTo(entity.id) {
                drawSegmentPath(context, path:entity.outline)
            }
            CGContextDrawPath(context, .Stroke)


            CGContextSetRGBFillColor(context, 1, 0.8, 0.2, 1)
            CGContextSetRGBStrokeColor(context, 0.8, 0.5, 0.1, 1)
            CGContextSetLineWidth(context, 1)
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }

            drawDotAt(context, position: active.position, size: dotSize*1.3)
            CGContextDrawPath(context, .FillStroke)            
        }
    }
}