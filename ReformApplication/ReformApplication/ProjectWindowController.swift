//
//  ProjectWindowController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa


class ProjectWindowController : NSWindowController {

    override func windowDidLoad() {
        if let screenFrame = window?.screen?.frame {
            window?.setFrame(NSRect(x:25, y:100, width: screenFrame.width-50, height: screenFrame.height-120), display: true)
            window?.center()
        }
            
    }
    
    @IBAction func toolbarButton(sender: NSToolbarItem) {
    
    }
    
}