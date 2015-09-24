//
//  CoreGraphics.swift
//  ReformGraphics
//
//  Created by Laszlo Korte on 16.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformMath

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
            case (.None, .Solid(let width, let sColor)):
                CGContextSetLineWidth(context, CGFloat(width))
                sColor.setAsStroke(context)
                CGContextDrawPath(context, CGPathDrawingMode.Stroke)
            case (.Fill(let bColor), .None):
                bColor.setAsBackground(context)
                CGContextDrawPath(context, CGPathDrawingMode.Fill)
            case (.None, .None): break
            }
        case .TextArea(let left, let right, let alignment, let text, let size):
            // TODO: not working

            let rotation = ReformMath.angle(right-left)
            let attr : [String:NSFont]
            if let font = NSFont(name: "Helvetica", size: CGFloat(size)) {
                attr = [NSFontAttributeName:font]
            } else {
                attr = [NSFontAttributeName:NSFont.systemFontOfSize(CGFloat(size))]
            }
            CGContextSaveGState(context);

            let attributedString = CFAttributedStringCreate(nil, text, attr)
            let line = CTLineCreateWithAttributedString(attributedString)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)

            let center = (left+right)/2
            let position : Vec2d
            switch alignment {
            case .Left: position = left
            case .Right: position = right
            case .Center: position = center
            }

            let xn : CGFloat

            switch alignment {
            case .Left: xn = CGFloat(position.x)
            case .Right: xn = CGFloat(position.x) - bounds.width
            case .Center: xn = CGFloat(position.x) - bounds.width/2
            }

            let yn = CGFloat(position.y) // - bounds.midY
            CGContextSetTextMatrix(context,CGAffineTransformMakeTranslation(xn, yn))

            CGContextTranslateCTM(context, CGFloat(position.x), CGFloat(position.y))
            CGContextRotateCTM(context, CGFloat(rotation.radians))
            CGContextTranslateCTM(context, -CGFloat(position.x), -CGFloat(position.y))

            CTLineDraw(line, context)
            CGContextFlush(context)

            CGContextRestoreGState(context)
        }
    }

    func drawOutline(context: CGContext, width: Double, color: Color) {
        switch self.area {
        case .PathArea(let path):
            path.draw(context)
            CGContextSetLineWidth(context, CGFloat(width))
            color.setAsStroke(context)
            CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        case .TextArea(let left, let right, let alignment, let text, let size):

            let rotation = ReformMath.angle(right-left)
            let attr : [String:AnyObject]
            let realFont : NSFont
            if let font = NSFont(name: "Helvetica", size: CGFloat(size)) {
                realFont = font
            } else {
                realFont = NSFont.systemFontOfSize(CGFloat(size))
            }

            let transparent = NSColor(red:0,green:0,blue:0,alpha:0)
            attr = [
                NSFontAttributeName:realFont,
                NSForegroundColorAttributeName:transparent,
                NSStrokeWidthAttributeName:width,
                NSStrokeColorAttributeName:NSColor(red: CGFloat(color.red), green: CGFloat(color.green), blue: CGFloat(color.blue), alpha: CGFloat(color.alpha))
            ]


            CGContextSaveGState(context);

            let attributedString = CFAttributedStringCreate(nil, text, attr)
            let line = CTLineCreateWithAttributedString(attributedString)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)

            let center = (left+right)/2
            let position : Vec2d
            switch alignment {
            case .Left: position = left
            case .Right: position = right
            case .Center: position = center
            }

            let xn : CGFloat

            switch alignment {
            case .Left: xn = CGFloat(position.x)
            case .Right: xn = CGFloat(position.x) - bounds.width
            case .Center: xn = CGFloat(position.x) - bounds.width/2
            }

            let yn = CGFloat(position.y) // - bounds.midY
            CGContextSetTextMatrix(context,CGAffineTransformMakeTranslation(xn, yn))

            CGContextTranslateCTM(context, CGFloat(position.x), CGFloat(position.y))
            CGContextRotateCTM(context, CGFloat(rotation.radians))
            CGContextTranslateCTM(context, -CGFloat(position.x), -CGFloat(position.y))

            CTLineDraw(line, context)
            CGContextFlush(context)
            
            CGContextRestoreGState(context)
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
            case .LineTo(let pos):
                CGContextAddLineToPoint(context, CGFloat(pos.x), CGFloat(pos.y))
            case .QuadraticTo(let pos, let cp):
                CGContextAddQuadCurveToPoint(context, CGFloat(cp.x), CGFloat(cp.y), CGFloat(pos.x), CGFloat(pos.y))
            case .QubicTo(let pos, let cp1, let cp2):
                CGContextAddCurveToPoint(context, CGFloat(cp1.x), CGFloat(cp1.y), CGFloat(cp2.x), CGFloat(cp2.y), CGFloat(pos.x), CGFloat(pos.y))
            case .ArcTo(let tanA, let tanB, let radius):
                CGContextAddArcToPoint(context, CGFloat(tanA.x), CGFloat(tanA.y), CGFloat(tanB.x), CGFloat(tanB.y), CGFloat(radius))
            case .Close:
                CGContextClosePath(context)
            }
        }
    }
}