//
//  MoveInstructionDetailController.swift
//  Reform
//
//  Created by Laszlo Korte on 01.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Cocoa
import ReformCore

class MoveInstructionDetailController : NSViewController {
    @IBOutlet var distanceLabel : NSTextField?

    override var representedObject : AnyObject? {
        didSet {
            updateLabel()
        }
    }

    override func viewDidLoad() {
        updateLabel()
    }

    func updateLabel() {
        guard let node = representedObject as? InstructionNode else {
            return
        }

        guard let instruction = node.instruction as? TranslateInstruction else {
            return
        }

        let labelText : String

        switch instruction.distance {
        case let d as RelativeDistance:
            labelText = "Relative"
        case let d as ConstantDistance:
            labelText = "Constant"
        default:
            return
        }

        distanceLabel?.stringValue = labelText
    }
}