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

class PictureController : NSViewController {

    @IBOutlet var stageController : StageController?

    private var stage : Stage?
    private var analyzer : Analyzer?
    private var runtime : Runtime?
    private var instructionFocus : InstructionFocus?
    private var toolController : ToolController?
    private var stageUI : StageUI?

    func setup(stage: Stage, analyzer: Analyzer, runtime: Runtime, instructionFocus : InstructionFocus, toolController: ToolController, stageUI : StageUI) {

        if let stageController = stageController {
            stageController.setup(stage, analyzer: analyzer, runtime: runtime, instructionFocus: instructionFocus, toolController: toolController, stageUI: stageUI)
        }

    }

    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        self.stageController = segue.destinationController as? StageController

    }

}

extension PictureController : NSSplitViewDelegate {

}