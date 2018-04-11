//
//  AttributesController.swift
//  Reform
//
//  Created by Laszlo Korte on 02.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Cocoa

class AttributesController : NSViewController {
    @IBOutlet var labelField : NSTextField?
    @IBOutlet var formNameField : NSTextField?
    @IBOutlet var tabs : NSTabView?
    @IBOutlet var singleTab : NSTabViewItem?
    @IBOutlet var multipleTab : NSTabViewItem?

    override var representedObject : Any? {
        didSet {
            attributesViewModel = representedObject as? AttributesViewModel
        }
    }

    var attributesViewModel : AttributesViewModel?

    override func viewDidAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(AttributesController.selectionChanged), name:NSNotification.Name("SelectionChanged"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(AttributesController.procedureChanged), name:NSNotification.Name("ProcedureAnalyzed"), object: nil)

        selectionChanged()
    }

    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name("SelectionChanged"), object: nil)


        NotificationCenter.default.removeObserver(self, name:NSNotification.Name("ProcedureAnalyzed"), object: nil)
    }

    @objc dynamic func selectionChanged() {
        if let model = attributesViewModel {
            tabs?.isHidden = false
            if let single = model.selection.one {
                tabs?.selectTabViewItem(singleTab)
                formNameField?.stringValue = model.analyzer.stringifier.labelFor(single) ?? String(describing: single)
            } else {
                tabs?.selectTabViewItem(multipleTab)
                labelField?.stringValue = "\(model.selection.selected.count) Forms selected"
            }
        } else {
            tabs?.isHidden = true
        }
    }

    @objc dynamic func procedureChanged() {
        if let
            model = attributesViewModel,
            let single = model.selection.one {
                formNameField?.stringValue = model.analyzer.stringifier.labelFor(single) ?? ""
        }
    }
}
