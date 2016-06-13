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

    func renderInContext(_ context: CGContext) {
        let inverse = CGFloat(1 / camera.zoom)

        context.setFillColor(red: 0.2, green: 0.7, blue: 1, alpha: 0.6)
        context.setStrokeColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.6)
        context.setLineWidth(5 * inverse)
        
        switch selectionUI.state {
        case .hide:
            break
        case .show(let selection):

            if lookIntoFuture {
                for identifiedShape in stage.finalShapes where selection.selected.contains(identifiedShape.id) {
                    identifiedShape.shape.drawOutline(context,width: 5/camera.zoom, color: ReformGraphics.Color(r: 90,g:177,b:83, a:255))
                }
                context.setStrokeColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
            }

            for entity in stage.entities where selection.selected.contains(entity.id.runtimeId) {
                if entity.type == .proxy {
                    context.setStrokeColor(red: 0.3843, green: 0.4157, blue: 1.0000, alpha: 0.6)
                } else {
                    context.setStrokeColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.6)
                }
                drawSegmentPath(context, path:entity.outline)
                
                context.drawPath(using: CGPathDrawingMode.stroke)
            }
        }

        switch selectionUI.rect {
        case .hide:
            break
        case .show(let min, let max):
            let rect = CGRect(x: Int(min.x), y:Int(min.y), width: Int(max.x - min.x), height: Int(max.y - min.y))
            context.setLineWidth(1 * inverse)
            context.setStrokeColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.6)
            context.setFillColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.1)

            context.stroke(rect)
            context.fill(rect)
        }
    }
}
