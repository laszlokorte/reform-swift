//
//  ExportController.swift
//  Reform
//
//  Created by Laszlo Korte on 07.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Cocoa
import ReformCore
import ReformSerializer

final class ExportController : NSViewController {
    @IBOutlet var jsonField : NSTextField?

    let jsonFormat = JsonFormat()

    var projectSession : ProjectSession? {
        didSet { updateJson() }
    }

    override func viewDidAppear() {
        updateJson()
    }

    func cancel(_ sender: AnyObject?) {
        dismissViewController(self)
    }

    func updateJson() {
        do {
            guard let normProj = try projectSession?.project.normalize() else {
                return
            }

            jsonField?.stringValue = jsonFormat.encode(normProj)
        } catch let e {
            jsonField?.stringValue = String(e)
        }
    }
}
