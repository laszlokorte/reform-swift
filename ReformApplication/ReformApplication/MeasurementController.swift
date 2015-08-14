//
//  MeasurementController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

class MeasurementController : NSViewController {

}

extension MeasurementController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 2
    }
}

extension MeasurementController : NSTableViewDelegate {
    
}