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
    var canvasSize = Vec2d(x: 100, y: 100) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
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
    private func fromEvent(event: NSEvent) -> Vec2d {
        return fromPoint(event.locationInWindow)
    }
    
    private func fromPoint(point: NSPoint) -> Vec2d {
        let pos = convertPoint(point, fromView: nil)
        
        return Vec2d(x: Double(pos.x-25), y: Double(pos.y-25))
    }
    
    override func mouseDown(theEvent: NSEvent) {
        toolController?.process(.Press, atPosition: fromEvent(theEvent), withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        toolController?.process(.Release, atPosition: fromEvent(theEvent), withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        
        toolController?.process(.Move, atPosition: fromEvent(theEvent), withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        toolController?.process(.Move, atPosition: fromEvent(theEvent), withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override func flagsChanged(theEvent: NSEvent) {
        guard let mousePostion = window?.mouseLocationOutsideOfEventStream else {
            return
        }
        
        toolController?.process(.ModifierChange, atPosition: fromPoint(mousePostion), withModifier: Modifier.fromEvent(theEvent))
        
        self.needsDisplay = true
    }
    
    override var acceptsFirstResponder : Bool { return true }
    
    override func keyDown(theEvent: NSEvent) {
        guard let mousePostion = window?.mouseLocationOutsideOfEventStream else {
            return
        }
        
        if theEvent.keyCode == 13 /*W*/ {
            toolController?.process(.Toggle, atPosition: fromPoint(mousePostion), withModifier: Modifier.fromEvent(theEvent))
        } else if theEvent.keyCode == 53 /*ESC*/ {
            toolController?.cancel()
        }else if theEvent.keyCode == 48 || theEvent.keyCode == 50 /*TAB*/ {
            toolController?.process(.Cycle, atPosition: fromPoint(mousePostion), withModifier: Modifier.fromEvent(theEvent))
        }
                
        if !theEvent.modifierFlags.isEmpty {
            toolController?.process(.ModifierChange, atPosition: fromPoint(mousePostion), withModifier: Modifier.fromEvent(theEvent))
        }
        self.needsDisplay = true

    }
    
    override func keyUp(theEvent: NSEvent) {
        guard let mousePostion = window?.mouseLocationOutsideOfEventStream else {
            return
        }
        
        if !theEvent.modifierFlags.isEmpty {
            toolController?.process(.ModifierChange, atPosition: fromPoint(mousePostion), withModifier: Modifier.fromEvent(theEvent))
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