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
import ReformExpression
import ReformTools
import ReformCore

typealias Picture = ReformCore.Picture

final class InstructionFocusChanger {
    let instructionFocus : InstructionFocus
    let intend : () -> ()

    init(instructionFocus : InstructionFocus, intend: @escaping () -> ()) {
        self.instructionFocus = instructionFocus
        self.intend = intend
    }

    func setFocus(_ node : InstructionNode?) {
        self.instructionFocus.current = node
        intend()
    }
}

final class FormSelectionChanger {
    let selection : FormSelection

    init(selection: FormSelection, intend: () -> ()) {
        self.selection = selection
    }

    func setSelection(_ ids: Set<FormIdentifier>) {
        self.selection.select(ids)
        publishChange()
    }

    fileprivate func publishChange() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SelectionChanged"), object: selection)
    }
}

final class ProcedureProcessor<A:Analyzer> {
    // The picture being edited, containing the instructions to produce th picture
    let picture : Picture

    // The Runtime used to evaluate the picture's instructions
    let runtime: DefaultRuntime

    // the analyzer used to to a static analysis on the picture
    let analyzer : A

    // the controller managing the tools used to edit the picture
    let toolController : ToolController

    // the runtime listener used to collect snapshots of the after each instruction
    let snapshotCollector : SnapshotCollector

    // the queue used to schedule tasks for the background thread
    let queue = DispatchQueue(label: "reform.runtime.queue")

    // counters to ensure runtime is not running multiple times in parallel
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
        triggerCounter += 1
        queue.async {
            [picture=self.picture, toolController=self.toolController, runtime=self.runtime, analyzer=self.analyzer] in
            do {
                defer { self.triggerCounter -= 1 }
                if self.triggerCounter > 1 {
                    return
                }
            }

            runtime.stop()
            self.snapshotCollector.requireRedraw()
            picture.procedure.analyzeWith(analyzer)

            DispatchQueue.main.sync {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ProcedureAnalyzed"), object: picture.procedure)
            }

            picture.procedure.evaluateWith(width: picture.size.0, height: picture.size.1,runtime: runtime)

            DispatchQueue.main.sync {
                toolController.currentTool.refresh()

            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ProcedureEvaluated"), object: picture.procedure)
            }
        }
    }

    func triggerEval() {
        evalCounter += 1

        queue.async {
            [picture=self.picture, toolController=self.toolController, runtime=self.runtime] in
            defer { self.evalCounter -= 1 }

            if self.evalCounter > 1 {
                return
            }

            runtime.stop()

            picture.procedure.evaluateWith(width: picture.size.0, height: picture.size.1,runtime: runtime)

            DispatchQueue.main.sync {
                toolController.currentTool.refresh()
            }
            DispatchQueue.main.async {

                NotificationCenter.default.post(name: Notification.Name(rawValue: "ProcedureEvaluated"), object: picture.procedure)
            }

        }
    }
}

final class PictureSession {
    // the project session this picture sessions belongs to
    private weak var projectSession : ProjectSession?

    // used to convert expressions into strings
    let expressionPrinter : ExpressionPrinter

    // the picture being edited in this session
    let picture : Picture

    // manages the form which is selected
    let formSelection : FormSelection

    // manages the instruction which is currently in focus
    let instructionFocus : InstructionFocus

    // analyzer to do a static analysis on the picture's instructions
    let analyzer : DefaultAnalyzer

    // runtime used to evaluate the picture
    let runtime : DefaultRuntime

    // generator for unique form identifiers
    let formIDSequence : IdentifierSequence<FormIdentifier>

    // generator for unique expression variable identifiers
    let referenceIDSequence : IdentifierSequence<ReferenceId>

    // the stage contains the result of the most recent picture evaluation
    let stage : Stage

    // the current UI state for rendering the stage
    let stageUI : StageUI

    // runtime listener collecting the shapes emitted during picture evaluation, passing them to the stage
    let stageCollector : StageCollector<DefaultAnalyzer>

    // runtime listener collecting a snapshot of the picture after each instruction during the evaluation
    let snapshotCollector : SnapshotCollector

    // the zoom and scroll position for looking at the stage
    let camera : Camera

    // service to search for snap points on the stage
    let pointSnapper : PointSnapper
    // service to search for grab points on the stage
    let pointGrabber : PointGrabber
    // service to search for handles on the stage
    let handleGrabber : HandleGrabber
    // service to search for affine handles on the stage
    let affineHandleGrabber : AffineHandleGrabber
    // service to search for crop handles on the stage
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


    let parserDelegate : ExpressionParserDelegate
    let parser : ShuntingYardParser<ExpressionParserDelegate>

    let lexer : Lexer<ShuntingYardTokenType> = lexerGenerator.getLexer()

    init(projectSession : ProjectSession, picture: ReformCore.Picture) {
        self.nameAllocator = NameAllocator()
        self.projectSession = projectSession
        self.picture = picture

        self.expressionPrinter = ExpressionPrinter(sheet: picture.data)

        let parserDelegate = ExpressionParserDelegate(sheet: picture.data)
        self.parserDelegate = parserDelegate
        self.parser = ShuntingYardParser(delegate: parserDelegate)

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
                [collector=self.stageCollector, triggerEval=self.procedureProcessor.triggerEval] in
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

        self.createRectTool = CreateFormTool(formType: RectangleForm.self, idSequence: self.formIDSequence, baseName: "Rectangle", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool, angleStep: Angle(degree: 90), ratio: (1,1))

        self.createCircleTool = CreateFormTool(formType: CircleForm.self, idSequence: self.formIDSequence, baseName: "Circle", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool, autoCenter: true)

        self.createPieTool = CreateFormTool(formType: PieForm.self, idSequence: self.formIDSequence, baseName: "Pie", nameAllocator: self.nameAllocator, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool, autoCenter: true)

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
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ToolChanged"), object: nil)
        }
    }
}
