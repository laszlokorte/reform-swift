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
    func setAsBackground(_ context: CGContext) {
        context.setFillColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }
    
    func setAsStroke(_ context: CGContext) {
        context.setStrokeColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }

    var toNSColor : NSColor {
        return NSColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha)/255)
    }
}

public extension Shape {
    func render(_ context: CGContext) {
        switch self.area {
        case .pathArea(let path):
            path.draw(context)
            
            switch (background, stroke) {
            case (.fill(let bColor), .solid(let width, let sColor)):
                context.setLineWidth(CGFloat(width))
                bColor.setAsBackground(context)
                sColor.setAsStroke(context)
                context.drawPath(using: CGPathDrawingMode.fillStroke)
            case (.none, .solid(let width, let sColor)):
                context.setLineWidth(CGFloat(width))
                sColor.setAsStroke(context)
                context.drawPath(using: CGPathDrawingMode.stroke)
            case (.fill(let bColor), .none):
                bColor.setAsBackground(context)
                context.drawPath(using: CGPathDrawingMode.fill)
            case (.none, .none): break
            }
        case .textArea(let left, let right, let alignment, let text, let size):
            let absSize = abs(size)

            let rotation = ReformMath.angle(signum(size)*(right-left))
            let font = NSFont(name: "Helvetica", size: CGFloat(absSize)) ?? NSFont.systemFont(ofSize: CGFloat(absSize))

            let backgroundColor : NSColor
            let strokeWidth : CGFloat
            let strokeColor : NSColor

            switch (background, stroke) {
            case (.fill(let bColor), .solid(let width, let sColor)):
                backgroundColor = bColor.toNSColor
                strokeColor = sColor.toNSColor
                strokeWidth = -CGFloat(100*width/size)
            case (.none, .solid(let width, let sColor)):
                backgroundColor = NSColor(red:0,green:0,blue:0,alpha:0)
                strokeColor = sColor.toNSColor
                // stroke width is relative to font size
                // https://developer.apple.com/library/mac/qa/qa1531/_index.html
                strokeWidth = CGFloat(50*width/absSize)
            case (.fill(let bColor), .none):
                backgroundColor = bColor.toNSColor
                strokeColor = NSColor(red:0,green:0,blue:0,alpha:0)
                strokeWidth = 0
            case (.none, .none): return
            }

            let attr : [String:Any] = [
                NSAttributedStringKey.font.rawValue:font,
                NSAttributedStringKey.foregroundColor.rawValue:backgroundColor,
                NSAttributedStringKey.strokeWidth.rawValue:strokeWidth,
                NSAttributedStringKey.strokeColor.rawValue:strokeColor
            ]

            context.saveGState()

            guard
                let attributedString = CFAttributedStringCreate(nil, text as CFString, attr as CFDictionary) else {
                return
            }
            let line = CTLineCreateWithAttributedString(attributedString)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)

            let center = (left+right)/2
            let position : Vec2d
            switch alignment {
            case .left: position = left
            case .right: position = right
            case .center: position = center
            }

            let xn : CGFloat

            switch alignment {
            case .left: xn = CGFloat(position.x)
            case .right: xn = CGFloat(position.x) - bounds.width
            case .center: xn = CGFloat(position.x) - bounds.width/2
            }

            let yn = CGFloat(position.y) // - bounds.midY
            context.textMatrix = CGAffineTransform(translationX: xn, y: yn)

            context.translateBy(x: CGFloat(position.x), y: CGFloat(position.y))
            context.rotate(by: CGFloat(rotation.radians))
            context.translateBy(x: -CGFloat(position.x), y: -CGFloat(position.y))

            CTLineDraw(line, context)
            context.flush()

            context.restoreGState()
        }
    }

    func drawOutline(_ context: CGContext, width: Double, color: Color) {
        switch self.area {
        case .pathArea(let path):
            path.draw(context)
            context.setLineWidth(CGFloat(width))
            color.setAsStroke(context)
            context.drawPath(using: CGPathDrawingMode.stroke)
        case .textArea(let left, let right, let alignment, let text, let size):
            let absSize = abs(size)

            let rotation = ReformMath.angle(signum(size)*(right-left))
            let font = NSFont(name: "Helvetica", size: CGFloat(absSize)) ?? NSFont.systemFont(ofSize: CGFloat(absSize))

            let transparent = NSColor(red:0,green:0,blue:0,alpha:0)
            let nsColor = color.toNSColor
            let attr : [String:Any] = [
                // stroke width is relative to font size
                // https://developer.apple.com/library/mac/qa/qa1531/_index.html
                NSAttributedStringKey.font.rawValue:font,
                NSAttributedStringKey.foregroundColor.rawValue:transparent,
                NSAttributedStringKey.strokeWidth.rawValue:(100*width/absSize),
                NSAttributedStringKey.strokeColor.rawValue:nsColor
            ]

            context.saveGState()

            guard let attributedString = CFAttributedStringCreate(nil, text as CFString, attr as CFDictionary) else {
                return
            }
            let line = CTLineCreateWithAttributedString(attributedString)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)

            let center = (left+right)/2
            let position : Vec2d
            switch alignment {
            case .left: position = left
            case .right: position = right
            case .center: position = center
            }

            let xn : CGFloat

            switch alignment {
            case .left: xn = CGFloat(position.x)
            case .right: xn = CGFloat(position.x) - bounds.width
            case .center: xn = CGFloat(position.x) - bounds.width/2
            }

            let yn = CGFloat(position.y) // - bounds.midY
            context.textMatrix = CGAffineTransform(translationX: xn, y: yn)

            context.translateBy(x: CGFloat(position.x), y: CGFloat(position.y))
            context.rotate(by: CGFloat(rotation.radians))
            context.translateBy(x: -CGFloat(position.x), y: -CGFloat(position.y))

            CTLineDraw(line, context)
            context.flush()
            
            context.restoreGState()
        }
    }
}

extension Path {
    public func draw(_ context: CGContext) {
        for segment in self {
            switch segment {
                
            case .moveTo(let pos):
                context.move(to: CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.y)))
            case .lineTo(let pos):
                context.addLine(to: CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.y)))
            case .quadraticTo(let pos, let cp):
                context.addQuadCurve(to: CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.y)), control: CGPoint(x: CGFloat(cp.x), y: CGFloat(cp.y)))
            case .qubicTo(let pos, let cp1, let cp2):
                context.addCurve(to: CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.y)), control1: CGPoint(x: CGFloat(cp1.x), y: CGFloat(cp1.y)), control2: CGPoint(x: CGFloat(cp2.x), y: CGFloat(cp2.y)))
            case .arcTo(let tanA, let tanB, let radius):
                context.addArc(tangent1End: CGPoint(x: CGFloat(tanA.x), y: CGFloat(tanA.y)), tangent2End: CGPoint(x: CGFloat(tanB.x), y: CGFloat(tanB.y)), radius: CGFloat(radius))
            case .close:
                context.closePath()
            }
        }
    }
}
