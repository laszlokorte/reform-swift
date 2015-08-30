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
    
    func renderInContext(context: CGContext) {
        CGContextSetRGBFillColor(context, 0.23, 0.85, 0.3, 1)
        CGContextSetRGBStrokeColor(context, 0.18, 0.5, 0.24, 1)
        CGContextSetLineWidth(context, 2)
        let dotSize : Double = 9
        
        
        switch cropUI.state {
        case .Hide:
            return
        case .Show(let points):
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            CGContextDrawPath(context, .FillStroke)


            break
        case .Active(let active, let points):

            CGContextSetRGBStrokeColor(context, 0.23, 0.85, 0.3, 1)
            CGContextSetLineWidth(context, 3)
            CGContextStrokeRect(context, CGRect(x:0,y:0, width: stage.size.x, height: stage.size.y))

            CGContextSetRGBFillColor(context, 0.23, 0.85, 0.3, 1)
            CGContextSetRGBStrokeColor(context, 0.18, 0.5, 0.24, 1)
            CGContextSetLineWidth(context, 2)

            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            CGContextDrawPath(context, .FillStroke)

            drawDotAt(context, position: active.position, size: dotSize*1.5)
            CGContextDrawPath(context, .FillStroke)

            break
            
        }
    }
}
