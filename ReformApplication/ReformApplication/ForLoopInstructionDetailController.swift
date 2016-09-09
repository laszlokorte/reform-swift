//
//  ForLoopInstructionDetailController.swift
//  Reform
//
//  Created by Laszlo Korte on 06.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import Cocoa
import ReformCore
import ReformExpression

class ForLoopInstructionDetailController : NSViewController, InstructionDetailController {

    @IBOutlet var errorLabel : NSTextField?
    @IBOutlet var countField : NSTextField?

    var stringifier : Stringifier?
    var parser : ((String) -> Result<ReformExpression.Expression, ShuntingYardError>)?
    var intend : (() -> ())?

    var error : String? {
        didSet {
            updateError()
        }
    }

    override var representedObject : Any? {
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

        guard let instruction = node.instruction as? ForLoopInstruction else {
            return
        }

        guard let stringifier = stringifier else {
            return
        }

        countField?.stringValue = stringifier.stringFor(instruction.expression) ?? ""
    }

    @IBAction func onChange(_ sender: Any?) {
        guard let
            parser = parser,
            let string = countField?.stringValue,
            let intend = intend
            else {
                return
        }

        guard let node = representedObject as? InstructionNode else {
            return
        }

        switch parser(string) {
        case .success(let expr):
            node.replaceWith(ForLoopInstruction(expression: expr))
            intend()
        case .fail(let err):
            print(err)
        }
    }
    
}
