//
//  ProcedureController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

class ProcedureController : NSViewController {
    @IBOutlet var tableView : NSTableView?
}

extension ProcedureController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 10
    }
}

extension ProcedureController : NSOutlineViewDataSource {
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return row % 3 == 0 ? 25 : 70
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellId = row%3==0 ? "groupCell" : "thumbnailCell"
        guard let cellView = tableView.makeViewWithIdentifier(cellId, owner: self) as? NSTableCellView else { return nil }
        
        
        let indent = cellView.constraints.filter { (constr) -> Bool in
            return constr.identifier == "indentSpace"
        }.first
        
        if let ind = indent {
            ind.constant = row % 2 == 0 ? 15 : 30
        }
        
        return cellView
    }
    }