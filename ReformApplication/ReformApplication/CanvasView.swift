//
//  CanvasView.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformGraphics
import ReformMath
import ReformStage
import ReformTools

protocol Renderer {
    func renderInContext(context: CGContext)
}

@IBDesignable
class CanvasView : NSView {
    var toolController : ToolController?
    var canvasSize = Vec2d(x: 300, y: 300)
    
    var shapes : [IdentifiedShape] = []
    var renderers : [Renderer] = []
    
    private var currentContext : CGContext? {
        get {
            // The 10.10 SDK provides a CGContext on NSGraphicsContext, but
            // that's not available to folks running 10.9, so perform this
            // violence to get a context via a void*.
            // iOS can just use UIGraphicsGetCurrentContext.
            
            let unsafeContextPointer = NSGraphicsContext.currentContext()?.graphicsPort
            
            if let contextPointer = unsafeContextPointer {
                let opaquePointer = COpaquePointer(contextPointer)
                let context: CGContextRef = Unmanaged.fromOpaque(opaquePointer).takeUnretainedValue()
                return context
            } else {
                return nil
            }
        }
    }
    
    
    override func drawRect(dirtyRect: NSRect) {
        if let context = currentContext {
            
            let offsetX = (bounds.width-CGFloat(canvasSize.x))/2.0
            let offsetY = (bounds.height-CGFloat(canvasSize.y))/2.0
            CGContextTranslateCTM(context, offsetX, offsetY)

            CGContextSetRGBFillColor(context, 1, 1, 1, 1)
            CGContextFillRect(context, CGRect(x:0,y:0, width: CGFloat(canvasSize.x), height: CGFloat(canvasSize.y)))
            
            for shape in shapes {
                shape.shape.render(context)
            }
            
            for r in renderers {
                r.renderInContext(context)
            }

        }
    }
    
    override var intrinsicContentSize : NSSize {
        return NSSize(width: canvasSize.x + 50, height: canvasSize.y + 50)
    }
}

extension CanvasView {
    override func mouseDown(theEvent: NSEvent) {
        toolController?.currentTool.process(.Press, withModifiers: [])
        
        self.needsDisplay = true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        toolController?.currentTool.process(.Release, withModifiers: [])
        
        self.needsDisplay = true
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        let pos = convertPoint(theEvent.locationInWindow, fromView: nil)
        toolController?.currentTool.process(.Move(position: Vec2d(x: Double(pos.x-25), y: Double(pos.y-25))), withModifiers: [])
        
        self.needsDisplay = true
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let pos = convertPoint(theEvent.locationInWindow, fromView: nil)
        toolController?.currentTool.process(.Move(position: Vec2d(x: Double(pos.x-25), y: Double(pos.y-25))), withModifiers: [])
        
        self.needsDisplay = true
    }
}

extension CropUI : Renderer {
    func renderInContext(context: CGContext) {
        CGContextSetRGBFillColor(context, 0.23, 0.85, 0.3, 1)
        CGContextSetRGBStrokeColor(context, 0.18, 0.5, 0.24, 1)
        CGContextSetLineWidth(context, 2)
        let dotSize : Double = 12
        
        
        switch state {
        case .Hide:
            return
        case .Show(let points):
            for p in points {
                
                let rect = CGRect(x:p.position.x-dotSize/2, y:p.position.y-dotSize/2, width: dotSize, height: dotSize)
                CGContextFillEllipseInRect(context, rect)
                CGContextStrokeEllipseInRect(context, rect)
            }
            
            break
        case .Active(let active, let points):
            for p in points {
                let rect = CGRect(x:p.position.x-dotSize/2, y:p.position.y-dotSize/2, width: dotSize, height: dotSize)
                CGContextFillEllipseInRect(context, rect)
                CGContextStrokeEllipseInRect(context, rect)
            }
            
            
            let rect = CGRect(x:active.position.x-1.5*dotSize/2, y:active.position.y-1.5*dotSize/2, width: 1.5*dotSize, height: 1.5*dotSize)
            CGContextFillEllipseInRect(context, rect)
            CGContextStrokeEllipseInRect(context, rect)
            break
            
        }
    }
}

extension SnapUI : Renderer {
    func renderInContext(context: CGContext) {
        CGContextSetRGBFillColor(context, 1, 0.8, 0.2, 1)
        CGContextSetRGBStrokeColor(context, 0.8, 0.5, 0.1, 1)
        CGContextSetLineWidth(context, 1)
        let dotSize : Double = 8
        
        
        switch state {
        case .Hide:
            return
        case .Show(let points):
            for p in points {
                
                let rect = CGRect(x:p.position.x-dotSize/2, y:p.position.y-dotSize/2, width: dotSize, height: dotSize)
                CGContextFillEllipseInRect(context, rect)
                CGContextStrokeEllipseInRect(context, rect)
            }
            
            break
        case .Active(let active, let points):
            for p in points {
                let rect = CGRect(x:p.position.x-dotSize/2, y:p.position.y-dotSize/2, width: dotSize, height: dotSize)
                CGContextFillEllipseInRect(context, rect)
                CGContextStrokeEllipseInRect(context, rect)
            }
            
            
            let rect = CGRect(x:active.position.x-1.5*dotSize/2, y:active.position.y-1.5*dotSize/2, width: 1.5*dotSize, height: 1.5*dotSize)
            CGContextFillEllipseInRect(context, rect)
            CGContextStrokeEllipseInRect(context, rect)
            break
            
        }
    }
}

class CenteredClipView:NSClipView
{
    override func constrainBoundsRect(proposedBounds: NSRect) -> NSRect {
        
        var rect = super.constrainBoundsRect(proposedBounds)
        if let containerView = self.documentView as? NSView {
            
            if (rect.size.width > containerView.frame.size.width) {
                rect.origin.x = (containerView.frame.width - rect.width ) / 2
            }
            
            if(rect.size.height > containerView.frame.size.height) {
                rect.origin.y = (containerView.frame.height - rect.height ) / 2
            }
        }
        
        return rect
    }
}