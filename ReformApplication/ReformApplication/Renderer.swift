//
//  Renderer.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformMath

protocol Renderer {
    func renderInContext(context: CGContext)
}

func drawDotAt(context: CGContext, position: Vec2d, size: Double) {
    let rect = CGRect(x:position.x-size/2, y:position.y-size/2, width: size, height: size)
    CGContextFillEllipseInRect(context, rect)
    CGContextStrokeEllipseInRect(context, rect)
}