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
import ReformGraphics

final class SelectionUIRenderer : Renderer {
    let selectionUI : SelectionUI
    let stage : Stage
    let camera: Camera
    var lookIntoFuture = false


    init(selectionUI : SelectionUI, stage : Stage, camera: Camera) {
        self.selectionUI = selectionUI
        self.stage = stage
        self.camera = camera
    }

    func renderInContext(context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)

        CGContextSetRGBFillColor(context, 0.2, 0.7, 1, 0.6)
        CGContextSetRGBStrokeColor(context, 0.2, 0.6, 0.9, 0.6)
        CGContextSetLineWidth(context, 5 * inverse)
        
        switch selectionUI.state {
        case .Hide:
            break
        case .Show(let selection):

            if lookIntoFuture {
                for identifiedShape in stage.finalShapes where selection.selected.contains(identifiedShape.id) {
                    identifiedShape.shape.drawOutline(context,width: 5/camera.zoom, color: Color(r: 90,g:177,b:83, a:255))
                }
                CGContextSetRGBStrokeColor(context, 0.2, 0.6, 0.9, 1)
            }

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
            CGContextSetLineWidth(context, 1 * inverse)
            CGContextSetRGBStrokeColor(context, 0.6, 0.6, 0.6, 0.6)
            CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 0.1)

            CGContextStrokeRect(context, rect)
            CGContextFillRect(context, rect)
        }
    }
}