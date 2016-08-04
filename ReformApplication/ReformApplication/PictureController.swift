//
//  PictureController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformCore
import ReformExpression
import ReformStage
import ReformMath
import ReformTools

final class PictureController : NSViewController {

    @IBOutlet weak var leftSplit: NSSplitView!
    @IBOutlet weak var centerSplit: NSView!
    @IBOutlet weak var rightSplit: NSView!

    override var representedObject: AnyObject? {
        didSet {
            guard let pictureSession = representedObject as? PictureSession else {
                return
            }
            if let stageController = stageController
            {
                updateStage(stageController, withSession: pictureSession)
            }

            if let procedureController = procedureController
            {
                updateProcedure(procedureController, withSession: pictureSession)
            }

            if let attributesController = attributesController
            {
                updateAttributes(attributesController, withSession: pictureSession)
            }
        }
    }

    var stageController : StageController? {
        didSet {
            if let pictureSession = representedObject as? PictureSession,
                let stageController = stageController {
                    updateStage(stageController, withSession: pictureSession)
            }
        }
    }

    var procedureController : ProcedureController? {
        didSet {
            if let pictureSession = representedObject as? PictureSession,
                let procedureController = procedureController {
                    updateProcedure(procedureController, withSession: pictureSession)
            }
        }
    }

    var attributesController : AttributesController? {
        didSet {
            if let pictureSession = representedObject as? PictureSession,
                let attributesController = attributesController {
                    updateAttributes(attributesController, withSession: pictureSession)
            }
        }
    }

    func updateStage(_ stage: StageController, withSession pictureSession: PictureSession) {
        stage.representedObject = StageViewModel(stage: pictureSession.stage, stageUI: pictureSession.stageUI, toolController: pictureSession.toolController, selection: pictureSession.formSelection, camera: pictureSession.camera, selectionChanger: pictureSession.formSelectionChanger)
    }

    func updateProcedure(_ procedureController: ProcedureController, withSession pictureSession: PictureSession) {
        procedureController.representedObject = ProcedureViewModel(analyzer: pictureSession.analyzer, instructionFocus: pictureSession.instructionFocus, snapshotCollector: pictureSession.snapshotCollector, instructionFocusChanger: pictureSession.instructionFocusChanger, formSelection: pictureSession.formSelection, formIdSequence: pictureSession.formIDSequence, nameAllocator: pictureSession.nameAllocator,
            lexer: pictureSession.lexer,
            parser: pictureSession.parser,
            instructionChanger: pictureSession.procedureProcessor.trigger)
    }

    func updateAttributes(_ attributesController: AttributesController, withSession pictureSession: PictureSession) {
        attributesController.representedObject = AttributesViewModel(stage: pictureSession.stage, selection: pictureSession.formSelection, analyzer: pictureSession.analyzer)
    }


    override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {

        if let s = segue.destinationController as? StageController {
            self.stageController = s
        }

        if let p = segue.destinationController as? ProcedureController {
            self.procedureController = p
        }

        if let p = segue.destinationController as? AttributesController {
            self.attributesController = p
        }

    }


}

extension PictureController : NSSplitViewDelegate {

    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return [leftSplit, rightSplit].contains(subview)
    }

    func splitView(_ splitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAt dividerIndex: Int) -> Bool {
        return false
    }

}
