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


class ProcedureSingleCellView : NSTableCellView, ProcedureCellView {
    @IBOutlet var labelField : NSTextField?
    @IBOutlet var previewImage : NSImageView?
    @IBOutlet var indentConstraint : NSLayoutConstraint?

    func configure(row: InstructionOutlineRow, procedureViewModel: ProcedureViewModel) {
        indentConstraint?.constant = CGFloat(15 * row.depth)
        labelField?.stringValue = row.label
        previewImage?.image = procedureViewModel.snapshotCollector.imageFor(InstructionNodeKey(row.node))

    }
}

class ProcedureGroupCellView : NSTableCellView, ProcedureCellView {
    @IBOutlet var labelField : NSTextField?
    @IBOutlet var indentConstraint : NSLayoutConstraint?


    func configure(row: InstructionOutlineRow, procedureViewModel: ProcedureViewModel) {
        indentConstraint?.constant = CGFloat(15 * row.depth)
        labelField?.stringValue = row.node.isEmpty ? "" : row.label
    }
}