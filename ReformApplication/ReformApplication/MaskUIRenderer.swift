//
//  MaskUIRenderer.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 30.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformStage
import ReformTools


struct MaskUIRenderer : Renderer {
    let maskUI : MaskUI

    func renderInContext(_ context: CGContext) {

        if case .clip(let x, let y, let width, let height) = maskUI.state {
            context.setFillColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
            context.fill(context.boundingBoxOfClipPath)

            context.clipTo(CGRect(x: x, y: y, width: width, height: height))
        }
        
    }
}
