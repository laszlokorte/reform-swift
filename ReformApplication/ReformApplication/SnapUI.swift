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
    let camera: Camera
    
    func renderInContext(_ context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)
        let dotSize : Double = 7 / camera.zoom
        
        
        switch snapUI.state {
        case .hide:
            return
        case .show(let points):
            
            context.setFillColor(red: 1, green: 0.8, blue: 0.2, alpha: 1)
            context.setStrokeColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 1)
            context.setLineWidth(1*inverse)
            for p in points {
                drawDotAt(context, position: p.position, size: p is GridSnapPoint ? 0.6*dotSize :dotSize)
            }
            context.drawPath(using: .fillStroke)
        case .active(let active, let points):
            context.setLineWidth(3*inverse)
            context.setStrokeColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1)

            for entity in stage.entities where active.belongsTo(entity.id.runtimeId) {
                drawSegmentPath(context, path:entity.outline)
            }
            context.drawPath(using: .stroke)


            context.setFillColor(red: 1, green: 0.8, blue: 0.2, alpha: 1)
            context.setStrokeColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 1)
            context.setLineWidth(1*inverse)
            for p in points {
                drawDotAt(context, position: p.position, size: p is GridSnapPoint ? 0.6*dotSize :dotSize)
            }
            context.drawPath(using: .fillStroke)


            drawDotAt(context, position: active.position, size: dotSize*1.3)
            context.drawPath(using: .fillStroke)            
        }
    }
}
