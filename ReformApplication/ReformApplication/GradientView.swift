//
//  GradientView.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 30.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

class GradientView : NSView {

    override func drawRect(dirtyRect: NSRect) {
        NSGradient(
            startingColor: NSColor(red: 0.8157, green:0.8118, blue: 0.8157, alpha: 1.0),
            endingColor: NSColor(red: 0.69, green:0.69, blue: 0.69, alpha: 1.0)

            )?.drawInRect(self.bounds, angle: -90)

    }
}
