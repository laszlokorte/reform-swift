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

struct SelectionUIRenderer : Renderer {
    let selectionUI : SelectionUI
    
    func renderInContext(context: CGContext) {
        CGContextSetRGBFillColor(context, 1, 0.8, 0.2, 1)
        CGContextSetRGBStrokeColor(context, 0.8, 0.5, 0.1, 1)
        CGContextSetLineWidth(context, 1)
        let dotSize : Double = 8
        
        
        switch selectionUI.state {
        case .Hide, .Show(.None):
            return
        case .Show(.Some(let formId)):
           
            break
            
            
        }
    }
}