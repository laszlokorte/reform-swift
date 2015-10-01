//
//  ProcedureController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformExpression
import ReformCore

final class ProcedureController : NSViewController {
    private var cycle = false

    override var representedObject : AnyObject? {
        didSet {
            procedureViewModel = representedObject as? ProcedureViewModel
        }
    }

    var procedureViewModel : ProcedureViewModel? {
        didSet {
            procedureChanged()
        }
    }

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "procedureEvaluated", name:"ProcedureEvaluated", object: nil)
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
        }

    }

    dynamic func procedureEvaluated() {
        instructions = procedureViewModel?.analyzer.instructions ?? []

        if let focus = procedureViewModel?.instructionFocus.current,
            index = instructions.indexOf({ $0.node === focus }) {

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

extension ProcedureController : NSTableViewDelegate {
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let outlineRow = instructions[row]

        return outlineRow.isGroup || outlineRow.node.isEmpty ? 25 : 70
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < instructions.count else { return nil }

        let outlineRow = instructions[row]
        let cellId = outlineRow.isGroup || outlineRow.node.isEmpty ? "groupCell" : "thumbnailCell"
        let cellView = tableView.makeViewWithIdentifier(cellId, owner: self)
        
        if let cell = cellView as? ProcedureCellView, procedureViewModel = procedureViewModel {
            cell.configure(instructions[row], procedureViewModel: procedureViewModel)
        }

        
        return cellView
    }


    func tableViewSelectionDidChange(aNotification: NSNotification) {
        if !cycle, let index = tableView?.selectedRow where index > -1 {
            procedureViewModel?.instructionFocusChanger.setFocus(instructions[index].node)
        }
    }
}

extension ProcedureController : NSMenuDelegate {
    @IBAction func wrapInstructionInLoop(sender: AnyObject) {
        guard let selectedIndexes = tableView?.selectedRowIndexes where selectedIndexes.count > 0 else {
            return
        }

        guard let seq = InstructionNodeSequence(nodes: selectedIndexes.map { instructions[$0].node }) else {
            return
        }

        seq.wrapIn(ForLoopInstruction(expression: .Constant(Value(int: 10))))

        procedureViewModel?.instructionChanger()
    }

    @IBAction func unwrapInstruction(sender: AnyObject) {
        guard let selectedIndex = tableView?.selectedRow where selectedIndex > 0 else {
            return
        }

        instructions[selectedIndex].node.unwrap()
        
        procedureViewModel?.instructionChanger()
    }

    @IBAction func wrapInstructionInCondition(sender: AnyObject) {
        guard let selectedIndex = tableView?.selectedRow where selectedIndex > 0 else {
            return
        }

        instructions[selectedIndex].node.wrapIn(IfConditionInstruction(expression: .Constant(Value(bool: true))))

        procedureViewModel?.instructionChanger()
    }

    @IBAction func createIterator(sender: AnyObject) {
        guard let selectedIndex = tableView?.selectedRow where selectedIndex > 0 else {
            return
        }

        if instructions[selectedIndex].node.isDeeperThan(2) {
            return
        }

        guard let formIds = procedureViewModel?.formSelection.selected where !formIds.isEmpty else {
            return
        }

        guard let formId = procedureViewModel?.formIdSequence.emitId() else {
            return
        }

        guard let name = procedureViewModel?.nameAllocator.alloc("Proxy") else {
            return
        }

        let node = InstructionNode(group:
            FormIteratorInstruction(proxyForm:
                ProxyForm(id: formId, name: name), formIds: Array(formIds)))

        
        node.append(child: InstructionNode())
        instructions[selectedIndex].node.append(sibling:
            node
        )
        procedureViewModel?.instructionChanger()
    }

    @IBAction func delete(sender: AnyObject) {
        guard let indices = tableView?.selectedRowIndexes else {
            return
        }

        for index in indices {
            let node = instructions[index].node
            guard !node.isEmpty else {
                continue
            }
            node.removeFromParent()
        }

        let validIndices = indices.filter({!instructions[$0].node.isEmpty})
        procedureViewModel?.instructionChanger()

        if let min = validIndices.minElement() {
            tableView?.selectRowIndexes(NSIndexSet(index: min-1), byExtendingSelection: false)
        }

    }

    @IBAction func doubleClick(sender: AnyObject) {

        guard let popOverViewController = storyboard?.instantiateControllerWithIdentifier("instructionDetailController") as? NSViewController else {
            return
        }


        guard let row = tableView?.selectedRow where row > 0, let cell = tableView?.viewAtColumn(0, row: row, makeIfNecessary: false) else {
            return
        }


        self.presentViewController(popOverViewController, asPopoverRelativeToRect: cell.frame, ofView: cell, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)

    }
}