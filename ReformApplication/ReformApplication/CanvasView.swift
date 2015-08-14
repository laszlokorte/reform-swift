//
//  CanvasView.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
class CanvasView : NSView {
    let paperColor = NSColor.whiteColor()
    
    let canvasSize = (300,300)
    
    override func drawRect(dirtyRect: NSRect) {
        let ownBounds = bounds
        let paperRect = NSRect(x:(ownBounds.width-CGFloat(canvasSize.0))/2.0,y:(ownBounds.height-CGFloat(canvasSize.1))/2.0, width: CGFloat(canvasSize.0), height: CGFloat(canvasSize.1))
        
        paperColor.set()
        NSBezierPath.fillRect(paperRect)
        
    }
    
    override var intrinsicContentSize : NSSize {
        return NSSize(width: canvasSize.0 + 50, height: canvasSize.1 + 50)
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