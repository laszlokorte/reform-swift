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
    fileprivate var cycle = false

    override var representedObject : Any? {
        didSet {
            procedureViewModel = representedObject as? ProcedureViewModel
        }
    }

    var procedureViewModel : ProcedureViewModel? {
        didSet {
            procedureChanged()
        }
    }

    override func viewDidAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(ProcedureController.procedureEvaluated), name:NSNotification.Name("ProcedureEvaluated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProcedureController.procedureChanged), name:NSNotification.Name("ProcedureAnalyzed"), object: nil)
    }

    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name("ProcedureEvaluated"), object: nil)

        NotificationCenter.default.removeObserver(self,  name:NSNotification.Name("ProcedureAnalyzed"), object: nil)
    }

    @objc dynamic func procedureChanged() {
        instructions = procedureViewModel?.analyzer.instructions ?? []
        cycle = true
        defer { cycle = false }

        tableView?.reloadData()

        if let focus = procedureViewModel?.instructionFocus.current,
            let index = instructions.index(where: { $0.node === focus }) {
                tableView?.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        }

    }

    @objc dynamic func procedureEvaluated() {
        instructions = procedureViewModel?.analyzer.instructions ?? []

    tableView?.reloadData(forRowIndexes: IndexSet(integersIn: 0..<instructions.count), columnIndexes: IndexSet(integer: 0))

        if let focus = procedureViewModel?.instructionFocus.current,
            let index = instructions.index(where: { $0.node === focus }) {

                tableView?.scrollRowToVisible(index)
        }
    }


    var instructions : [InstructionOutlineRow] = []

    @IBOutlet var tableView : NSTableView?
}

extension ProcedureController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return instructions.count
    }

}

extension ProcedureController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let outlineRow = instructions[row]

        return outlineRow.isGroup || outlineRow.node.isEmpty ? 25 : 70
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < instructions.count else { return nil }

        let outlineRow = instructions[row]
        let cellId = outlineRow.isGroup || outlineRow.node.isEmpty ? "groupCell" : "thumbnailCell"
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellId), owner: self)
        
        if let cell = cellView as? ProcedureCellView, let procedureViewModel = procedureViewModel {
            cell.configure(instructions[row], procedureViewModel: procedureViewModel)
        }

        
        return cellView
    }


    func tableViewSelectionDidChange(_ aNotification: Notification) {
        if !cycle, let index = tableView?.selectedRow , index > -1 {
            procedureViewModel?.instructionFocusChanger.setFocus(instructions[index].node)
        }
    }
}

extension ProcedureController : NSMenuDelegate {
    @IBAction func wrapInstructionInLoop(_ sender: Any) {
        guard let selectedIndexes = tableView?.selectedRowIndexes, selectedIndexes.count > 0 else {
            return
        }

        guard let seq = InstructionNodeSequence(nodes: selectedIndexes.map { instructions[$0].node }) else {
            return
        }

        if seq.wrapIn(ForLoopInstruction(expression: .constant(ReformExpression.Value(int: 10)))) {
            procedureViewModel?.instructionChanger()
        }
    }

    @IBAction func unwrapInstruction(_ sender: Any) {
        guard let selectedIndex = tableView?.selectedRow, selectedIndex > 0 else {
            return
        }

        if instructions[selectedIndex].node.unwrap() {
            procedureViewModel?.instructionChanger()
        }
    }

    @IBAction func wrapInstructionInCondition(_ sender: Any) {
        guard let selectedIndexes = tableView?.selectedRowIndexes, selectedIndexes.count > 0 else {
            return
        }

        guard let seq = InstructionNodeSequence(nodes: selectedIndexes.map { instructions[$0].node }) else {
            return
        }

        if seq.wrapIn(IfConditionInstruction(expression: .constant(ReformExpression.Value(bool: true)))) {
            procedureViewModel?.instructionChanger()
        }
    }

    @IBAction func createIterator(_ sender: Any) {
        guard let selectedIndex = tableView?.selectedRow, selectedIndex > 0 else {
            return
        }

        if instructions[selectedIndex].node.isDeeperThan(2) {
            return
        }

        guard let formIds = procedureViewModel?.formSelection.selected, !formIds.isEmpty else {
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

        let child = InstructionNode()


        if node.append(child: child) &&
            instructions[selectedIndex].node.append(sibling:
        node
            ) {
                procedureViewModel?.instructionFocus.current = child
        }
        procedureViewModel?.instructionChanger()
    }

    @IBAction func delete(_ sender: Any) {
        guard let indices = tableView?.selectedRowIndexes else {
            return
        }

        for index in indices {
            let node = instructions[index].node
            if node.isEmpty {
                continue
            }
            if !node.removeFromParent() {
                break
            }
        }

        let validIndices = indices.filter({!instructions[$0].node.isEmpty})
        procedureViewModel?.instructionChanger()

        if let min = validIndices.min() {
            tableView?.selectRowIndexes(IndexSet(integer: min-1), byExtendingSelection: false)
        }

    }

    @IBAction func doubleClick(_ sender: Any) {

        guard let row = tableView?.selectedRow, row > 0, let cell = tableView?.view(atColumn: 0, row: row, makeIfNecessary: false) else {
            return
        }


        let controllerID : String

        switch instructions[row].node.instruction {
        case _ as ForLoopInstruction:
            controllerID = "forInstructionDetailController"
        case _ as IfConditionInstruction:
            controllerID = "ifInstructionDetailController"
        case _ as FormIteratorInstruction:
            controllerID = "iteratorInstructionDetailController"
        case _ as CreateFormInstruction:
            controllerID = "createFormInstructionDetailController"
        case _ as TranslateInstruction:
            controllerID = "translateInstructionDetailController"
        case _ as RotateInstruction:
            controllerID = "rotateInstructionDetailController"
        case _ as ScaleInstruction:
            controllerID = "scaleInstructionDetailController"
        case _ as MorphInstruction:
            controllerID = "morphInstructionDetailController"
        default:
            return
        }

        guard let popOverViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: controllerID)) as? NSViewController else {
            return
        }

        if let instr = popOverViewController as? InstructionDetailController, let procedureViewModel = procedureViewModel{
            instr.stringifier = procedureViewModel.analyzer.stringifier
            instr.parser = { string in
                return procedureViewModel.parser.parse(procedureViewModel.lexer.tokenize(string))
            }
            instr.intend = procedureViewModel.instructionChanger
            
            let key = InstructionNodeKey(instructions[row].node)

            instr.error = procedureViewModel.snapshotCollector.errors[key].map{String(describing: $0)}
        }
        popOverViewController.representedObject = instructions[row].node

        self.presentViewController(popOverViewController, asPopoverRelativeTo: cell.frame, of: cell, preferredEdge: NSRectEdge.maxX, behavior: NSPopover.Behavior.transient)

    }
}
