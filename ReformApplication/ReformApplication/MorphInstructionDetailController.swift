//
//  MorphInstructionDetailController.swift
//  Reform
//
//  Created by Laszlo Korte on 06.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import Cocoa
import ReformCore

class MorphInstructionDetailController : NSViewController, InstructionDetailController {

    @IBOutlet var errorLabel : NSTextField?

    var stringifier : Stringifier?

    var error : String? {
        didSet {
            updateError()
        }
    }

    override var representedObject : AnyObject? {
        didSet {
            updateLabel()
        }
    }

    override func viewDidLoad() {
        updateLabel()
        updateError()
    }

    func updateError() {
        if let error = error {
            errorLabel?.stringValue = error
            errorLabel?.hidden = false
        } else {
            errorLabel?.hidden = true
        }
    }

    func updateLabel() {
    }
    
}