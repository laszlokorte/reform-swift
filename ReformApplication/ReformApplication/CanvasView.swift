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
        toolController?.currentTool.process(.Press, withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        toolController?.currentTool.process(.Release, withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        let pos = convertPoint(theEvent.locationInWindow, fromView: nil)
        toolController?.currentTool.process(.Move(position: Vec2d(x: Double(pos.x-25), y: Double(pos.y-25))), withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let pos = convertPoint(theEvent.locationInWindow, fromView: nil)
        toolController?.currentTool.process(.Move(position: Vec2d(x: Double(pos.x-25), y: Double(pos.y-25))), withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func flagsChanged(theEvent: NSEvent) {
        toolController?.currentTool.process(.ModifierChange, withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override var acceptsFirstResponder : Bool { return true }
    
    override func keyDown(theEvent: NSEvent) {
        if theEvent.keyCode == 13 {
            toolController?.currentTool.process(.Toggle, withModifier: Modifier.fromEvent(theEvent))
            
            Swift.print("Toggle")
        }
        
    }
    
    override func keyUp(theEvent: NSEvent) {
    
    
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