//
//  ProjectWindowController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformCore
import ReformExpression
import ReformStage
import ReformMath
import ReformTools

class ProjectWindowController : NSWindowController {

    var procedure = Procedure()
    lazy var picture : ReformCore.Picture = ReformCore.Picture(identifier : PictureIdentifier(0), name: "Untiled", size: (580,330), procedure: self.procedure)

    lazy var project : Project = Project(pictures: self.picture)

    let sheet = BaseSheet()
    lazy var expressionPrinter : ExpressionPrinter = ExpressionPrinter(sheet: self.sheet)


    lazy var analyzer : DefaultAnalyzer = DefaultAnalyzer(expressionPrinter : self.expressionPrinter)
    let runtime = DefaultRuntime()


    let formIdSequence = IdentifierSequence(type: FormIdentifier.self, initialValue: 100)

    let instructionFocus = InstructionFocus()
    let formSelection = FormSelection()
    let stage = Stage()

    let selectionUI = SelectionUI()
    let snapUI = SnapUI()
    let grabUI = GrabUI()
    let pivotUI = PivotUI()
    let handleUI = HandleUI()
    let cropUI = CropUI()

    lazy var pointSnapper : PointSnapper = PointSnapper(stage: self.stage, snapUI: self.snapUI, radius: 10)
    lazy var pointGrabber : PointGrabber = PointGrabber(stage: self.stage, grabUI: self.grabUI, radius: 10)
    lazy var handleGrabber : HandleGrabber = HandleGrabber(stage: self.stage, handleUI: self.handleUI, radius: 10)

    lazy var streightener : Streightener = Streightener()
    lazy var aligner : Aligner = Aligner()

    lazy var instructionCreator : InstructionCreator = InstructionCreator(focus: self.instructionFocus, notifier: self.procedureChanged)

    lazy var selectionTool : SelectionTool = SelectionTool(stage: self.stage, selection: self.formSelection, selectionUI: self.selectionUI)


    lazy var createLineTool : CreateFormTool = CreateFormTool(formType: LineForm.self, idSequence: self.formIdSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

    lazy var createRectTool : CreateFormTool = CreateFormTool(formType: RectangleForm.self, idSequence: self.formIdSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

    lazy var createCircleTool : CreateFormTool = CreateFormTool(formType: CircleForm.self, idSequence: self.formIdSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

    lazy var createPieTool : CreateFormTool = CreateFormTool(formType: PieForm.self, idSequence: self.formIdSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

    lazy var createArcTool : CreateFormTool = CreateFormTool(formType: ArcForm.self, idSequence: self.formIdSequence, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)

    lazy var moveTool : MoveTool = MoveTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)

    lazy var morphTool : MorphTool = MorphTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)

    lazy var rotationTool : RotateTool = RotateTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool, pivotUI: self.pivotUI)


    lazy var scalingTool : ScaleTool = ScaleTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool, pivotUI: self.pivotUI)

    let toolController = ToolController()
    

    override func windowDidLoad() {
        if let screenFrame = window?.screen?.frame {
            window?.setFrame(NSRect(x:25, y:100, width: screenFrame.width-50, height: screenFrame.height-120), display: true)
            window?.center()
        }

        toolController.currentTool = rotationTool

        let rectangleForm = RectangleForm(id: FormIdentifier(100), name: "Rectangle 1")

        let lineForm = LineForm(id: FormIdentifier(101), name: "Line 1")

        let rectangleDestination = RelativeDestination(
            from: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.TopLeft.rawValue),
            to: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.Center.rawValue)
        )

        let lineDestination = RelativeDestination(
            from: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.TopLeft.rawValue),
            to: ForeignFormPoint(formId: rectangleForm.identifier, pointId: RectangleForm.PointId.BottomLeft.rawValue)
        )

        let createInstruction = CreateFormInstruction(form: rectangleForm, destination: rectangleDestination)

        let node1 = InstructionNode(instruction: createInstruction)

        procedure.root.append(child: node1)

        let moveInstruction = TranslateInstruction(formId: rectangleForm.identifier, distance: RelativeDistance(
            from: ForeignFormPoint(formId: rectangleForm.identifier, pointId: RectangleForm.PointId.Center.rawValue),
            to: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.Center.rawValue),
            direction: FreeDirection()))

        let node2 = InstructionNode(instruction: moveInstruction)

        procedure.root.append(child: node2)

        let rotateInstruction = RotateInstruction(
            formId: rectangleForm.identifier,
            angle: ConstantAngle(angle: Angle(percent: 20)),
            fixPoint: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.Center.rawValue)
        )

        let node3 = InstructionNode(instruction: rotateInstruction)

        procedure.root.append(child: node3)

        let createLineInstruction = CreateFormInstruction(form: lineForm, destination: lineDestination)
        let node4 = InstructionNode(instruction: createLineInstruction)

        procedure.root.append(child: node4)

        instructionFocus.current = node2

        if let pictureController = contentViewController as? PictureController {

            let stageUI = StageUI(selectionUI: selectionUI, snapUI: snapUI, grabUI: grabUI, handleUI: handleUI, pivotUI: pivotUI, cropUI: cropUI)
            pictureController.setup(stage, analyzer: analyzer, runtime: runtime, instructionFocus: instructionFocus, toolController: toolController, stageUI: stageUI)
        }
    }
    


    func procedureChanged() {
        procedure.analyzeWith(analyzer)
        procedure.evaluateWith(width: picture.size.0, height: picture.size.1,runtime: runtime)

        //        print("Entities:")
        //        for e in stage.entities {
        //            print(e)
        //        }

        //        print("Final Shapes:")
        //        for s in stage.currentShapes {
        //            print(s)
        //        }

        toolController.currentTool.refresh()
    }

    @IBAction func selectToolCreateLine(sender: AnyObject) {
        toolController.currentTool = createLineTool
    }

    @IBAction func selectToolCreateRectangle(sender: AnyObject) {
        toolController.currentTool = createRectTool
    }

    @IBAction func selectToolCreateCircle(sender: AnyObject) {
        toolController.currentTool = createCircleTool
    }

    @IBAction func selectToolCreatePie(sender: AnyObject) {
        toolController.currentTool = createPieTool
    }

    @IBAction func selectToolCreateArc(sender: AnyObject) {
        toolController.currentTool = createArcTool
    }

    @IBAction func selectToolMove(sender: AnyObject) {
        toolController.currentTool = moveTool
    }


    @IBAction func selectToolMorph(sender: AnyObject) {
        toolController.currentTool = morphTool
    }


    @IBAction func selectToolRotate(sender: AnyObject) {
        toolController.currentTool = rotationTool
    }


    @IBAction func selectToolScale(sender: AnyObject) {
        toolController.currentTool = scalingTool
    }

    override func validateToolbarItem(theItem: NSToolbarItem) -> Bool {

        if let _ = ToolbarIdentifier(rawValue: theItem.itemIdentifier) {
            return true
        } else {
            return false
        }
    }

    @IBAction func toolbarButton(sender: NSToolbarItem) {
    }

    enum ToolbarIdentifier : String {
        case LineToolItem
        case RectangleToolItem
        case CircleToolItem
        case PieToolItem
        case ArcToolItem

        case MoveToolItem
        case RotateToolItem
        case ScaleToolItem
        case MorphToolItem
    }
    
}