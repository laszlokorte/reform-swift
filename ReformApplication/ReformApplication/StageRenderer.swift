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
    var lookIntoFuture = false

    init(stage: Stage) {
        self.stage = stage
    }

    func renderInContext(context: CGContext) {

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


    }
}