//
//  StageRenderer.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 30.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformCore
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

    func renderInContext(_ context: CGContext) {
        let inverse = CGFloat(1/camera.zoom)
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(CGRect(x:0,y:0, width: CGFloat(stage.size.x), height: CGFloat(stage.size.y)))


        if lookIntoFuture {
            for shape in stage.finalShapes {
                shape.shape.render(context)
            }

            context.setAlpha(0.5)
        }


        for shape in stage.currentShapes {
            shape.shape.render(context)
        }

        if case .disabled = maskUI.state {
            context.setStrokeColor(red: 0.3843, green: 0.4157, blue: 1.0000, alpha: 0.6)
            context.setLineWidth(1.5*inverse)

            for entity in stage.entities where entity.type == .proxy{
                drawSegmentPath(context, path:entity.outline)

                context.drawPath(using: CGPathDrawingMode.stroke)
            }

            context.setStrokeColor(red: 0.73, green: 0.62, blue: 0.54, alpha: 0.4)

            context.setLineWidth(1.5*inverse)

            for entity in stage.entities where entity.formType == PictureForm.self {
                drawSegmentPath(context, path:entity.outline)

                context.drawPath(using: CGPathDrawingMode.stroke)
            }
        }
    }
}
