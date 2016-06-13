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
    
    func renderInContext(_ context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)

        context.setFillColor(red: 0.23, green: 0.85, blue: 0.3, alpha: 1)
        context.setStrokeColor(red: 0.18, green: 0.5, blue: 0.24, alpha: 1)
        context.setLineWidth(2 * inverse)
        let dotSize : Double = 9 / camera.zoom
        
        
        switch cropUI.state {
        case .hide:
            return
        case .show(let points):
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            context.drawPath(using: .fillStroke)
        case .active(let active, let points):

            context.setStrokeColor(red: 0.23, green: 0.85, blue: 0.3, alpha: 1)
            context.setLineWidth(3 * inverse)
            context.stroke(CGRect(x:0,y:0, width: stage.size.x, height: stage.size.y))

            context.setFillColor(red: 0.23, green: 0.85, blue: 0.3, alpha: 1)
            context.setStrokeColor(red: 0.18, green: 0.5, blue: 0.24, alpha: 1)
            context.setLineWidth(2 * inverse)

            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            context.drawPath(using: .fillStroke)

            drawDotAt(context, position: active.position, size: dotSize*1.5)
            context.drawPath(using: .fillStroke)
        }
    }
}
