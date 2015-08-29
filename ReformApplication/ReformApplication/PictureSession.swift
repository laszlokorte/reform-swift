//
//  PictureSession.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression
import ReformStage
import ReformMath
import ReformTools
import ReformCore

typealias Picture = ReformCore.Picture

class InstructionFocusChanger {
    let instructionFocus : InstructionFocus
    let callback : () -> ()

    init(instructionFocus : InstructionFocus, callback: () -> ()) {
        self.instructionFocus = instructionFocus
        self.callback = callback
    }

    func setFocus(node : InstructionNode?) {
        self.instructionFocus.current = node
        callback()
    }
}

class ProcedureProcessor {
    let picture : Picture
    let runtime: Runtime
    let analyzer : Analyzer
    let toolController : ToolController

    init(picture : Picture, analyzer: Analyzer, runtime: Runtime, toolController: ToolController) {
        self.picture = picture
        self.analyzer = analyzer
        self.runtime = runtime
        self.toolController = toolController
    }

    func trigger() {
        picture.procedure.analyzeWith(analyzer)
        picture.procedure.evaluateWith(width: picture.size.0, height: picture.size.1,runtime: runtime)

        //        print("Entities:")
        //        for e in stage.entities {
        //            print(e)
        //        }

        //        print("Final Shapes:")
        //        for s in stage.currentShapes {
        //            print(s)
        //        }

        toolController.currentTool.refresh()
    NSNotificationCenter.defaultCenter().postNotificationName("ProcedureEvaluated", object: picture.procedure)
    }
}

class PictureSession {
    private weak var projectSession : ProjectSession?

    let expressionPrinter : ExpressionPrinter

    let picture : Picture
    let formSelection : FormSelection
    let instructionFocus : InstructionFocus
    let analyzer : DefaultAnalyzer
    let runtime : Runtime

    let formIDSequence : IdentifierSequence<FormIdentifier>
    let referenceIDSequence : IdentifierSequence<ReferenceId>

    let stage : Stage
    let stageUI : StageUI

    let stageCollector : StageCollector
    let snapshotCollector : SnapshotCollector

    let pointSnapper : PointSnapper
    let pointGrabber : PointGrabber
    let handleGrabber : HandleGrabber
    let cropGrabber : CropGrabber

    let streightener : Streightener
    let aligner : Aligner

    let instructionCreator : InstructionCreator

    let toolController : ToolController

    let selectionTool : SelectionTool
    let createLineTool : CreateFormTool
    let createRectTool : CreateFormTool
    let createCircleTool : CreateFormTool
    let createPieTool : CreateFormTool
    let createArcTool : CreateFormTool
    let moveTool : MoveTool
    let morphTool : MorphTool
    let rotationTool : RotateTool
    let scalingTool : ScaleTool

    let cropTool : CropTool

    let procedureProcessor : ProcedureProcessor
    let instructionFocusChanger : InstructionFocusChanger

    init(projectSession : ProjectSession, picture: ReformCore.Picture) {
        self.projectSession = projectSession
        self.picture = picture

        self.expressionPrinter = ExpressionPrinter(sheet: picture.data)

        self.instructionFocus = InstructionFocus()
        self.formSelection = FormSelection()
        self.analyzer = DefaultAnalyzer(expressionPrinter: expressionPrinter)
        self.runtime = DefaultRuntime()
        self.formIDSequence = IdentifierSequence(initialValue: 100)
        self.referenceIDSequence = IdentifierSequence(initialValue: 100)


        self.stage = Stage()
        self.stageUI = StageUI()

        self.stageCollector = StageCollector(stage: stage, analyzer: analyzer, focusFilter: self.instructionFocus.isCurrent)

        self.snapshotCollector = SnapshotCollector(maxSize: (120,80))

        runtime.listeners.append(stageCollector)
        runtime.listeners.append(snapshotCollector)


        self.pointSnapper = PointSnapper(stage: self.stage, snapUI: self.stageUI.snapUI, radius: 10)
        self.pointGrabber = PointGrabber(stage: self.stage, grabUI: self.stageUI.grabUI, radius: 10)
        self.handleGrabber = HandleGrabber(stage: self.stage, handleUI: self.stageUI.handleUI, radius: 10)
        self.cropGrabber = CropGrabber(stage: stage, cropUI: self.stageUI.cropUI, radius: 10)

        self.streightener = Streightener()
        self.aligner = Aligner()

        self.toolController = ToolController()


        self.procedureProcessor = ProcedureProcessor(picture: picture, analyzer: self.analyzer, runtime: self.runtime, toolController: self.toolController)

        self.instructionFocusChanger = InstructionFocusChanger(instructionFocus: self.instructionFocus, callback: self.procedureProcessor.trigger)

        self.instructionCreator = InstructionCreator(focus: self.instructionFocus, notifier: self.procedureProcessor.trigger)
        self.selectionTool = SelectionTool(stage: self.stage, selection: self.formSelection, selectionUI: self.stageUI.selectionUI)


        self.createLineTool = CreateFormTool(formType: LineForm.self, idSequence: self.formIDSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createRectTool = CreateFormTool(formType: RectangleForm.self, idSequence: self.formIDSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createCircleTool = CreateFormTool(formType: CircleForm.self, idSequence: self.formIDSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createPieTool = CreateFormTool(formType: PieForm.self, idSequence: self.formIDSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createArcTool = CreateFormTool(formType: ArcForm.self, idSequence: self.formIDSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.moveTool = MoveTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)

        self.morphTool = MorphTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)

        self.rotationTool = RotateTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool, pivotUI: self.stageUI.pivotUI)


        self.scalingTool = ScaleTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool, pivotUI: self.stageUI.pivotUI)

        self.cropTool = CropTool(stage: self.stage, cropGrabber: self.cropGrabber, streightener: self.streightener, picture: self.picture, callback: self.procedureProcessor.trigger)

        self.toolController.currentTool = selectionTool
    }

    func refresh() {
        self.procedureProcessor.trigger()
    }

    var tool : Tool {
        get {
            return toolController.currentTool
        }

        set {
            toolController.currentTool = newValue
            NSNotificationCenter.defaultCenter().postNotificationName("ToolChanged", object: nil)
        }
    }
}