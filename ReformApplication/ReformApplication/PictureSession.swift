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

final class InstructionFocusChanger {
    let instructionFocus : InstructionFocus
    let intend : () -> ()

    init(instructionFocus : InstructionFocus, intend: () -> ()) {
        self.instructionFocus = instructionFocus
        self.intend = intend
    }

    func setFocus(node : InstructionNode?) {
        self.instructionFocus.current = node
        intend()
    }
}

final class FormSelectionChanger {
    let selection : FormSelection

    init(selection: FormSelection, intend: () -> ()) {
        self.selection = selection
    }

    func setSelection(ids: Set<FormIdentifier>) {
        self.selection.select(ids)
        publishChange()
    }

    private func publishChange() {
        NSNotificationCenter.defaultCenter().postNotificationName("SelectionChanged", object: selection)
    }
}

final class ProcedureProcessor<A:Analyzer> {
    let picture : Picture
    let runtime: DefaultRuntime
    let analyzer : A
    let toolController : ToolController
    let snapshotCollector : SnapshotCollector
    let queue = dispatch_queue_create("reform.runtime.queue", DISPATCH_QUEUE_SERIAL)

    var triggerCounter = 0
    var evalCounter = 0

    init(picture : Picture, analyzer: A, runtime: DefaultRuntime, toolController: ToolController, snapshotCollector : SnapshotCollector) {
        self.picture = picture
        self.analyzer = analyzer
        self.runtime = runtime
        self.toolController = toolController
        self.snapshotCollector = snapshotCollector
    }

    func trigger() {
        triggerCounter++
        dispatch_async(queue) {
            [picture=self.picture, toolController=self.toolController, runtime=self.runtime, analyzer=self.analyzer] in
            do {
                defer { self.triggerCounter-- }
                if self.triggerCounter > 1 {
                    return
                }
            }

            runtime.stop()
            self.snapshotCollector.requireRedraw()
            picture.procedure.analyzeWith(analyzer)

            dispatch_sync(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName("ProcedureAnalyzed", object: picture.procedure)
            }

            picture.procedure.evaluateWith(width: picture.size.0, height: picture.size.1,runtime: runtime)

            dispatch_sync(dispatch_get_main_queue()) {
                toolController.currentTool.refresh()

            }
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName("ProcedureEvaluated", object: picture.procedure)
            }
        }
    }

    func triggerEval() {
        evalCounter++
        dispatch_async(queue) {
            [picture=self.picture, toolController=self.toolController, runtime=self.runtime] in
            defer { self.evalCounter-- }

            if self.evalCounter > 1 {
                return
            }

            runtime.stop()

            picture.procedure.evaluateWith(width: picture.size.0, height: picture.size.1,runtime: runtime)

            dispatch_sync(dispatch_get_main_queue()) {
                toolController.currentTool.refresh()
            }
            dispatch_async(dispatch_get_main_queue()) {

                NSNotificationCenter.defaultCenter().postNotificationName("ProcedureEvaluated", object: picture.procedure)
            }

        }
    }
}

final class PictureSession {
    private weak var projectSession : ProjectSession?

    let expressionPrinter : ExpressionPrinter

    let picture : Picture
    let formSelection : FormSelection
    let instructionFocus : InstructionFocus
    let analyzer : DefaultAnalyzer
    let runtime : DefaultRuntime

    let formIDSequence : IdentifierSequence<FormIdentifier>
    let referenceIDSequence : IdentifierSequence<ReferenceId>

    let stage : Stage
    let stageUI : StageUI

    let stageCollector : StageCollector<DefaultAnalyzer>
    let snapshotCollector : SnapshotCollector

    let camera : Camera
    let pointSnapper : PointSnapper
    let pointGrabber : PointGrabber
    let handleGrabber : HandleGrabber
    let affineHandleGrabber : AffineHandleGrabber
    let cropGrabber : CropGrabber

    let streightener : Streightener
    let aligner : Aligner

    let nameAllocator : NameAllocator
    let instructionCreator : InstructionCreator

    let toolController : ToolController

    let selectionTool : SelectionTool
    let createLineTool : CreateFormTool
    let createRectTool : CreateFormTool
    let createCircleTool : CreateFormTool
    let createPieTool : CreateFormTool
    let createArcTool : CreateFormTool
    let createTextTool : CreateFormTool
    let createPictureTool : CreateFormTool
    let moveTool : MoveTool
    let morphTool : MorphTool
    let rotationTool : RotateTool
    let scalingTool : ScaleTool
    let previewTool : PreviewTool

    let cropTool : CropTool

    let procedureProcessor : ProcedureProcessor<DefaultAnalyzer>
    let instructionFocusChanger : InstructionFocusChanger
    let formSelectionChanger : FormSelectionChanger

    init(projectSession : ProjectSession, picture: ReformCore.Picture) {
        self.nameAllocator = NameAllocator()
        self.projectSession = projectSession
        self.picture = picture

        self.expressionPrinter = ExpressionPrinter(sheet: picture.data)

        self.instructionFocus = InstructionFocus()
        self.formSelection = FormSelection()
        self.analyzer = DefaultAnalyzer(expressionPrinter: expressionPrinter, nameAllocator: nameAllocator)
        self.runtime = DefaultRuntime()
        self.formIDSequence = IdentifierSequence(initialValue: 100)
        self.referenceIDSequence = IdentifierSequence(initialValue: 100)


        self.stage = Stage()
        self.stageUI = StageUI()

        self.stageCollector = StageCollector(stage: stage, analyzer: analyzer, focusFilter: self.instructionFocus.isCurrent)

        self.snapshotCollector = SnapshotCollector(maxSize: (90,56))

        runtime.listeners.append(stageCollector)
        runtime.listeners.append(snapshotCollector)


        self.camera = Camera()
        self.pointSnapper = PointSnapper(stage: self.stage, snapUI: self.stageUI.snapUI, camera: camera, radius: 10)
        self.pointGrabber = PointGrabber(stage: self.stage, grabUI: self.stageUI.grabUI, camera: camera, radius: 10)
        self.handleGrabber = HandleGrabber(stage: self.stage, handleUI: self.stageUI.handleUI, camera: camera, radius: 10)
        self.affineHandleGrabber = AffineHandleGrabber(stage: self.stage, affineHandleUI: self.stageUI.affineHandleUI, camera: camera, radius: 10)
        self.cropGrabber = CropGrabber(stage: stage, cropUI: self.stageUI.cropUI, camera: camera, radius: 10)

        self.streightener = Streightener()
        self.aligner = Aligner()

        self.toolController = ToolController()


        self.procedureProcessor = ProcedureProcessor(picture: picture, analyzer: self.analyzer, runtime: self.runtime, toolController: self.toolController, snapshotCollector : self.snapshotCollector)

        self.instructionFocusChanger = InstructionFocusChanger(instructionFocus: self.instructionFocus) {
                [collector=self.stageCollector, triggerEval=self.procedureProcessor.triggerEval] b in
                collector.recalcIntersections = true
                triggerEval()
            }

        self.formSelectionChanger = FormSelectionChanger(selection: self.formSelection) {

        }

        self.instructionCreator = InstructionCreator(stage: self.stage, focus: self.instructionFocus) {
            [collector=self.stageCollector, trigger=self.procedureProcessor.trigger] b in
            if b {
            collector.recalcIntersections = true
            }
            trigger()
        }

        self.selectionTool = SelectionTool(stage: self.stage, selection: self.formSelection, selectionUI: self.stageUI.selectionUI, indend: formSelectionChanger.publishChange)


        self.createLineTool = CreateFormTool(formType: LineForm.self, idSequence: self.formIDSequence, baseName: "Line", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createRectTool = CreateFormTool(formType: RectangleForm.self, idSequence: self.formIDSequence, baseName: "Rectangle", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createCircleTool = CreateFormTool(formType: CircleForm.self, idSequence: self.formIDSequence, baseName: "Circle", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createPieTool = CreateFormTool(formType: PieForm.self, idSequence: self.formIDSequence, baseName: "Pie", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createArcTool = CreateFormTool(formType: ArcForm.self, idSequence: self.formIDSequence, baseName: "Arc", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createTextTool = CreateFormTool(formType: TextForm.self, idSequence: self.formIDSequence, baseName: "Text", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.createPictureTool = CreateFormTool(formType: PictureForm.self, idSequence: self.formIDSequence, baseName: "Picture", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

        self.moveTool = MoveTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)

        self.morphTool = MorphTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)

        self.rotationTool = RotateTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.affineHandleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool, pivotUI: self.stageUI.pivotUI)


        self.scalingTool = ScaleTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.affineHandleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool, pivotUI: self.stageUI.pivotUI)

        self.cropTool = CropTool(stage: self.stage, cropGrabber: self.cropGrabber, streightener: self.streightener, picture: self.picture) {
            [trigger=self.procedureProcessor.trigger,collector=self.stageCollector] in
            collector.recalcIntersections = true
            trigger()
        }

        self.previewTool = PreviewTool(stage: self.stage, maskUI: stageUI.maskUI)

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