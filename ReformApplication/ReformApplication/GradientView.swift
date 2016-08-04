//
//  GradientView.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 30.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

final class GradientView : NSView {

    override func draw(_ dirtyRect: NSRect) {
        if let main = self.window?.isKeyWindow, !main {
            NSGradient(
                starting: NSColor(red: 0.9647, green:0.9647, blue: 0.9647, alpha: 1.0),
                ending: NSColor(red: 0.9647, green:0.9647, blue: 0.9647, alpha: 1.0)

                )?.draw(in: self.bounds, angle: -90)
        } else {
            NSGradient(
                starting: NSColor(red: 0.8157, green:0.8118, blue: 0.8157, alpha: 1.0),
                ending: NSColor(red: 0.69, green:0.69, blue: 0.69, alpha: 1.0)

                )?.draw(in: self.bounds, angle: -90)
        }

    }

}
