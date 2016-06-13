//
//  GrabUI.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformTools
import ReformStage

struct GrabUIRenderer : Renderer {
    let grabUI : GrabUI
    let camera: Camera
    
    func renderInContext(_ context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)

        context.setFillColor(red: 0.2, green: 0.7, blue: 1, alpha: 1)
        context.setStrokeColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
        context.setLineWidth(1 * inverse)
        let dotSize : Double = 7 / camera.zoom
        
        
        switch grabUI.state {
        case .hide:
            return
        case .show(let points):
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            context.drawPath(using: .fillStroke)
        case .active(let active, let points):
            for p in points {
                drawDotAt(context, position: p.position, size: dotSize)
            }
            context.drawPath(using: .fillStroke)

            drawDotAt(context, position: active.position, size: dotSize*1.5)
            
            context.drawPath(using: .fillStroke)
        }
    }
}
