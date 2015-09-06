//
//  HandleUI.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformTools
import ReformStage

struct HandleUIRenderer : Renderer {
    let handleUI : HandleUI
    let camera: Camera
    
    func renderInContext(context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)

        CGContextSetRGBFillColor(context, 0.1, 0.9, 0.6, 1)
        CGContextSetRGBStrokeColor(context, 0, 0.6, 0.4, 1)
        CGContextSetLineWidth(context, 1 * inverse)
        let dotSize : Double = 8 / camera.zoom
        
        
        switch handleUI.state {
        case .Hide:
            return
        case .Show(let points):
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            
            CGContextDrawPath(context, .FillStroke)
        case .Active(let active, let points):
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            CGContextDrawPath(context, .FillStroke)

            
            drawDotAt(context, position: active.position, size: dotSize*1.5)
            
            CGContextDrawPath(context, .FillStroke)
        }
    }
}