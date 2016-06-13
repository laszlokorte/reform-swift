//
//  MoveInstructionDetailController.swift
//  Reform
//
//  Created by Laszlo Korte on 01.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Cocoa
import ReformCore
import ReformExpression

class MoveInstructionDetailController : NSViewController, InstructionDetailController {
    @IBOutlet var verticalDistanceField : NSTextField?
    @IBOutlet var horizontalDistanceField : NSTextField?
    @IBOutlet var relativeDistanceLabel : NSTextField?
    @IBOutlet var tabView : NSTabView?
    @IBOutlet var relativeDistanceTab : NSTabViewItem?
    @IBOutlet var constantDistanceTab : NSTabViewItem?

    @IBOutlet var errorLabel : NSTextField?


    var stringifier : Stringifier?
    var parser : ((String) -> Result<ReformExpression.Expression, ShuntingYardError>)?
    var intend : (() -> ())?

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
        if let e : String = error {
            errorLabel?.stringValue = e
            if let errorLabel = errorLabel {
                self.view.addSubview(errorLabel)
            }
        } else {
            errorLabel?.removeFromSuperview()
        }
    }

    func updateLabel() {
        guard let node = representedObject as? InstructionNode else {
            return
        }

        guard let instruction = node.instruction as? TranslateInstruction else {
            return
        }

        guard let stringifier = stringifier else {
            return
        }

        switch instruction.distance {
        case let d as RelativeDistance:
            relativeDistanceLabel?.stringValue = "\(d.from.getDescription(stringifier)) to \(d.to.getDescription(stringifier))"
            tabView?.selectTabViewItem(relativeDistanceTab)
        case let d as ConstantDistance:
            tabView?.selectTabViewItem(constantDistanceTab)
            horizontalDistanceField?.doubleValue = d.delta.x
            verticalDistanceField?.doubleValue = d.delta.y
        default:
            return
        }
    }
}
