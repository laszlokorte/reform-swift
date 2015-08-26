//
//  CoreGraphics.swift
//  ReformGraphics
//
//  Created by Laszlo Korte on 16.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation

internal extension Color {
    func setAsBackground(context: CGContext) {
        CGContextSetRGBFillColor(context, CGFloat(red)/255.0, CGFloat(green)/255.0, CGFloat(blue)/255.0, CGFloat(alpha)/255.0)
    }
    
    func setAsStroke(context: CGContext) {
        CGContextSetRGBStrokeColor(context, CGFloat(red)/255.0, CGFloat(green)/255.0, CGFloat(blue)/255.0, CGFloat(alpha)/255.0)
    }
}

public extension Shape {
    func render(context: CGContext) {
        switch self.area {
        case .PathArea(let path):
            path.draw(context)
            
            switch (background, stroke) {
            case (.Fill(let bColor), .Solid(let width, let sColor)):
                CGContextSetLineWidth(context, CGFloat(width))
                bColor.setAsBackground(context)
                sColor.setAsStroke(context)
                CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
                break
            case (.None, .Solid(let width, let sColor)):
                CGContextSetLineWidth(context, CGFloat(width))
                sColor.setAsStroke(context)
                CGContextDrawPath(context, CGPathDrawingMode.Stroke)
                break

            case (.Fill(let bColor), .None):
                bColor.setAsBackground(context)
                CGContextDrawPath(context, CGPathDrawingMode.Fill)

                break
            case (.None, .None): break

                
            }
            
            break
        case .TextArea:
            // TODO: not working
            
            fatalError("Font rendering not implemented")
//            CGContextSetTextPosition(context, CGFloat(position.x), CGFloat(position.y))
//            if let font = NSFont(name: "Helvetica", size: CGFloat(size)) {
//                let attr = [NSFontAttributeName:font]
//                let attributedString = CFAttributedStringCreate(nil, text, attr)
//                let line = CTLineCreateWithAttributedString(attributedString)
//                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
//                
//                let xn = CGFloat(position.x) - bounds.width/2
//                let yn = CGFloat(position.y) // - bounds.midY
//                CGContextSetTextPosition(context, xn, yn)
//                
//                CGContextSetFontSize(context, CGFloat(size))
//                CTLineDraw(line, context)
//                CGContextFlush(context)
//
//                
//            }
            break
        }
    }
}

extension Path {
    public func draw(context: CGContext) {
        for segment in self {
            context
            switch segment {
                
            case .MoveTo(let pos):
                CGContextMoveToPoint(context, CGFloat(pos.x), CGFloat(pos.y))
                break
            case .LineTo(let pos):
                CGContextAddLineToPoint(context, CGFloat(pos.x), CGFloat(pos.y))
                break
            case .QuadraticTo(let pos, let cp):
                CGContextAddQuadCurveToPoint(context, CGFloat(cp.x), CGFloat(cp.y), CGFloat(pos.x), CGFloat(pos.y))
                break
            case .QubicTo(let pos, let cp1, let cp2):
                CGContextAddCurveToPoint(context, CGFloat(cp1.x), CGFloat(cp1.y), CGFloat(cp2.x), CGFloat(cp2.y), CGFloat(pos.x), CGFloat(pos.y))
                break
            case .ArcTo(let tanA, let tanB, let radius):
                CGContextAddArcToPoint(context, CGFloat(tanA.x), CGFloat(tanA.y), CGFloat(tanB.x), CGFloat(tanB.y), CGFloat(radius))
                break
            case .Close:
                CGContextClosePath(context)
                break
            }
        }
    }
}