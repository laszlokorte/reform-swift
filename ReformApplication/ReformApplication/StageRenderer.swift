//
//  StageRenderer.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 30.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformStage
import ReformTools


final class StageRenderer : Renderer {
    let stage : Stage
    let camera: Camera
    let maskUI: MaskUI

    var lookIntoFuture = false

    init(stage: Stage, camera : Camera, maskUI : MaskUI) {
        self.stage = stage
        self.camera = camera
        self.maskUI = maskUI
    }

    func renderInContext(context: CGContext) {
        let inverse = CGFloat(1/camera.zoom)
        CGContextSetRGBFillColor(context, 1, 1, 1, 1)
        CGContextFillRect(context, CGRect(x:0,y:0, width: CGFloat(stage.size.x), height: CGFloat(stage.size.y)))


        if lookIntoFuture {
            for shape in stage.finalShapes {
                shape.shape.render(context)
            }

            CGContextSetAlpha(context, 0.5)
        }


        for shape in stage.currentShapes {
            shape.shape.render(context)
        }

        if case .Disabled = maskUI.state {
            CGContextSetRGBStrokeColor(context, 0.3843, 0.4157, 1.0000, 0.6)
            CGContextSetLineWidth(context, 1.5*inverse)

            for entity in stage.entities where entity.type == .Proxy{
                drawSegmentPath(context, path:entity.outline)

                CGContextDrawPath(context, CGPathDrawingMode.Stroke)
            }
        }
    }
}