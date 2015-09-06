//
//  CropUI.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformTools
import ReformStage

struct CropUIRenderer : Renderer {
    let stage : Stage
    let cropUI : CropUI
    let camera: Camera
    
    func renderInContext(context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)

        CGContextSetRGBFillColor(context, 0.23, 0.85, 0.3, 1)
        CGContextSetRGBStrokeColor(context, 0.18, 0.5, 0.24, 1)
        CGContextSetLineWidth(context, 2 * inverse)
        let dotSize : Double = 9 / camera.zoom
        
        
        switch cropUI.state {
        case .Hide:
            return
        case .Show(let points):
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            CGContextDrawPath(context, .FillStroke)
        case .Active(let active, let points):

            CGContextSetRGBStrokeColor(context, 0.23, 0.85, 0.3, 1)
            CGContextSetLineWidth(context, 3 * inverse)
            CGContextStrokeRect(context, CGRect(x:0,y:0, width: stage.size.x, height: stage.size.y))

            CGContextSetRGBFillColor(context, 0.23, 0.85, 0.3, 1)
            CGContextSetRGBStrokeColor(context, 0.18, 0.5, 0.24, 1)
            CGContextSetLineWidth(context, 2 * inverse)

            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            CGContextDrawPath(context, .FillStroke)

            drawDotAt(context, position: active.position, size: dotSize*1.5)
            CGContextDrawPath(context, .FillStroke)
        }
    }
}
