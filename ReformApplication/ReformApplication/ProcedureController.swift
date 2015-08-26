//
//  ProcedureController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa
import ReformCore

class ProcedureController : NSViewController {
    private var cycle = false

    override var representedObject : AnyObject? {
        didSet {
            print("didSet repr")

            procedureViewModel = representedObject as? ProcedureViewModel
        }
    }

    var procedureViewModel : ProcedureViewModel? {
        didSet {
            procedureChanged()
        }
    }

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "procedureChanged", name:"ProcedureChanged", object: nil)
    }

    dynamic func procedureChanged() {
        instructions = procedureViewModel?.analyzer.instructions ?? []
        cycle = true
        defer { cycle = false }

        tableView?.reloadData()

        if let focus = procedureViewModel?.instructionFocus.current,
            index = instructions.indexOf({ $0.node === focus }) {
                tableView?.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)

                print("scroll \(index)")
                tableView?.scrollRowToVisible(index)
        }
    }


    var instructions : [InstructionOutlineRow] = []

    @IBOutlet var tableView : NSTableView?
}

extension ProcedureController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return instructions.count
    }
}

extension ProcedureController : NSOutlineViewDelegate {
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return instructions[row].isGroup ? 25 : 70
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellId = instructions[row].isGroup ? "groupCell" : "thumbnailCell"
        let cellView = tableView.makeViewWithIdentifier(cellId, owner: self)
        
        if let cell = cellView as? ProcedureCellView {
            cell.configure(instructions[row])
        }

        
        return cellView
    }

    func tableViewSelectionDidChange(aNotification: NSNotification) {
        if !cycle, let index = tableView?.selectedRow {
            procedureViewModel?.instructionFocus.current = instructions[index].node
        }
    }
}