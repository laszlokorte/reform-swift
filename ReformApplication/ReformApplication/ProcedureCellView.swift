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
    func configure(row: InstructionOutlineRow, procedureViewModel: ProcedureViewModel)
}


final class ProcedureSingleCellView : NSTableCellView, ProcedureCellView {
    @IBOutlet var indentConstraint : NSLayoutConstraint?

    func configure(row: InstructionOutlineRow, procedureViewModel: ProcedureViewModel) {
        indentConstraint?.constant = CGFloat(15 * row.depth)
        textField?.stringValue = row.label
        imageView?.image = procedureViewModel.snapshotCollector.imageFor(InstructionNodeKey(row.node))


        let error = procedureViewModel.snapshotCollector.errors.keys.contains(InstructionNodeKey(row.node))
        textField?.textColor = error ? NSColor.redColor() : nil

    }
}

final class ProcedureGroupCellView : NSTableCellView, ProcedureCellView {
    @IBOutlet var indentConstraint : NSLayoutConstraint?


    func configure(row: InstructionOutlineRow, procedureViewModel: ProcedureViewModel) {
        indentConstraint?.constant = CGFloat(15 * row.depth)
        textField?.stringValue = row.node.isEmpty ? "" : row.label

        let error = procedureViewModel.snapshotCollector.errors.keys.contains(InstructionNodeKey(row.node))
        textField?.textColor = error ? NSColor.redColor() : nil

    }
}