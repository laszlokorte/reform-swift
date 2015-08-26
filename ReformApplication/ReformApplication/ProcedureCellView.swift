//
//  ProcedureCellView.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformCore

protocol ProcedureCellView {
    func configure(node: InstructionOutlineRow)
}

class ProcedureSingleCellView : NSTableCellView, ProcedureCellView {
    @IBOutlet var labelField : NSTextField?
    @IBOutlet var indentConstraint : NSLayoutConstraint?

    func configure(node: InstructionOutlineRow) {
        indentConstraint?.constant = CGFloat(15 * node.depth)
        labelField?.stringValue = node.label

    }
}

class ProcedureGroupCellView : NSTableCellView, ProcedureCellView {
    @IBOutlet var labelField : NSTextField?
    @IBOutlet var indentConstraint : NSLayoutConstraint?

    func configure(node: InstructionOutlineRow) {
        indentConstraint?.constant = CGFloat(15 * node.depth)
        labelField?.stringValue = node.label
    }
}