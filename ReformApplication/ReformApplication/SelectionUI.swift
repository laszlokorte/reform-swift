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
        CGContextSetRGBFillColor(context, 0.2, 0.7, 1, 0.6)
        CGContextSetRGBStrokeColor(context, 0.2, 0.6, 0.9, 0.6)
        CGContextSetLineWidth(context, 5)
        
        switch selectionUI.state {
        case .Hide:
            return
        case .Show(let selection):
            if let entity = selection.selected {
                for case .Line(let line) in entity.outline {
                    CGContextMoveToPoint(context, CGFloat(line.from.x), CGFloat(line.from.y))
                    CGContextAddLineToPoint(context, CGFloat(line.to.x), CGFloat(line.to.y))
                }
                
                CGContextDrawPath(context, CGPathDrawingMode.Stroke)
            }
           
            break
            
            
        }
    }
}