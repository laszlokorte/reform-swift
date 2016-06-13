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
    let camera: Camera
    
    func renderInContext(_ context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)

        context.setFillColor(red: 0.9, green: 0.3, blue: 0.8, alpha: 1)
        context.setStrokeColor(red: 0.8, green: 0.2, blue: 0.7, alpha: 1)
        context.setLineWidth(1*inverse)
        let dotSize : Double = 4 / camera.zoom
        
        switch pivotUI.state {
        case .hide:
            return
        case .show(let point):
            drawDotAt(context, position: point.position, size: dotSize*1.5)
            context.drawPath(using: .fillStroke)
        }
        
    }
}
