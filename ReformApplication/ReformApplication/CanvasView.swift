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
    @IBOutlet weak var delegate : NSViewController?

    var canvasSize = Vec2d(x: 100, y: 100) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var camera : Camera? = nil
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
            if let camera = camera {
                camera.zoom = Double(self.convertSize(NSSize(width:1, height: 1), toView: nil).width)
            }

            let offsetX = (bounds.width-CGFloat(canvasSize.x))/2.0
            let offsetY = (bounds.height-CGFloat(canvasSize.y))/2.0
            CGContextTranslateCTM(context, offsetX, offsetY)

            for r in renderers {
                r.renderInContext(context)
            }
        }
    }
    
    override var intrinsicContentSize : NSSize {
        return NSSize(width: canvasSize.x + 50, height: canvasSize.y + 50)
    }

    override var acceptsFirstResponder : Bool { return true }

    override func keyDown(theEvent: NSEvent) {
        delegate?.keyDown(theEvent)
    }

    override func keyUp(theEvent: NSEvent) {
        delegate?.keyUp(theEvent)
    }

}
