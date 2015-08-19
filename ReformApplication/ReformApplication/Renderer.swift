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
    CGContextAddEllipseInRect(context, rect)
}


func drawSegmentPath(context: CGContext, path: SegmentPath) {
    for case .Line(let line) in path {
        CGContextMoveToPoint(context, CGFloat(line.from.x), CGFloat(line.from.y))
        CGContextAddLineToPoint(context, CGFloat(line.to.x), CGFloat(line.to.y))
    }
}