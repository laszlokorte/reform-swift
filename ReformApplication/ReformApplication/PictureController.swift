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
        }
    }

    var stageController : StageController? {
        didSet {
            if let pictureSession = representedObject as? PictureSession,
                stageController = stageController {
                    updateStage(stageController, withSession: pictureSession)
            }
        }
    }

    var procedureController : ProcedureController? {
        didSet {
            if let pictureSession = representedObject as? PictureSession,
                procedureController = procedureController {
                    updateProcedure(procedureController, withSession: pictureSession)
            }
        }
    }

    func updateStage(stage: StageController, withSession pictureSession: PictureSession) {
        stage.representedObject = StageViewModel(stage: pictureSession.stage, stageUI: pictureSession.stageUI, toolController: pictureSession.toolController, camera: pictureSession.camera)
    }

    func updateProcedure(procedureController: ProcedureController, withSession pictureSession: PictureSession) {
        procedureController.representedObject = ProcedureViewModel(analyzer: pictureSession.analyzer, instructionFocus: pictureSession.instructionFocus, snapshotCollector: pictureSession.snapshotCollector, instructionFocusChanger: pictureSession.instructionFocusChanger, instructionChanger: pictureSession.procedureProcessor.trigger)
    }


    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {

        if let s = segue.destinationController as? StageController {
            self.stageController = s
        }

        if let p = segue.destinationController as? ProcedureController {
            self.procedureController = p
        }

    }


}

extension PictureController : NSSplitViewDelegate {

}