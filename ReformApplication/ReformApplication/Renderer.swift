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
    func renderInContext(_ context: CGContext)
}

func drawDotAt(_ context: CGContext, position: Vec2d, size: Double) {
    let rect = CGRect(x:position.x-size/2, y:position.y-size/2, width: size, height: size)
    context.addEllipse(in: rect)
}


func drawSegmentPath(_ context: CGContext, path: SegmentPath) {
    for segment in path {
        switch segment {
        case .line(let line):
            context.move(to: CGPoint(x: CGFloat(line.from.x), y: CGFloat(line.from.y)))
            context.addLine(to: CGPoint(x: CGFloat(line.to.x), y: CGFloat(line.to.y)))
        case .arc(let arc):
            let startPoint = arc.center + Vec2d(radius: arc.radius, angle: arc.range.start)
            context.move(to: CGPoint(x: CGFloat(startPoint.x), y: CGFloat(startPoint.y)))
            context.addArc(center: CGPoint(x: CGFloat(arc.center.x), y: CGFloat(arc.center.y)), radius: CGFloat(arc.radius), startAngle: CGFloat(arc.range.start.radians), endAngle: CGFloat(arc.range.end.radians), clockwise: false)
        }
        
        
    }
}
