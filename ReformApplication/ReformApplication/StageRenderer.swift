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


struct StageRenderer : Renderer {
    let stage : Stage

    func renderInContext(context: CGContext) {

        CGContextSetRGBFillColor(context, 1, 1, 1, 1)
        CGContextFillRect(context, CGRect(x:0,y:0, width: CGFloat(stage.size.x), height: CGFloat(stage.size.y)))


        for shape in stage.currentShapes {
            shape.shape.render(context)
        }

    }
}