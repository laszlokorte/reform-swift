//
//  StageController.swift
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

class StageController : NSViewController {
    
    let sheet = BaseSheet()
    lazy var expressionPrinter : ExpressionPrinter = ExpressionPrinter(sheet: self.sheet)
    
    
    lazy var analyzer : DefaultAnalyzer = DefaultAnalyzer(expressionPrinter : self.expressionPrinter)
    let runtime = DefaultRuntime()

    
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
    lazy var createFormTool : CreateFormTool = CreateFormTool(stage: self.stage, selection: self.formSelection, pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, aligner: self.aligner, instructionCreator: self.instructionCreator, selectionTool: self.selectionTool)
    
    lazy var moveTool : MoveTool = MoveTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, pointGrabber: self.pointGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)
    
    lazy var morphTool : MorphTool = MorphTool(stage: self.stage,  selection:self.formSelection,  pointSnapper: self.pointSnapper, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)
    
    lazy var rotationTool : RotateTool = RotateTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool)

    
    lazy var scalingTool : ScaleTool = ScaleTool(stage: self.stage,  selection:self.formSelection, handleGrabber: self.handleGrabber, streightener: self.streightener, instructionCreator: self.instructionCreator,selectionTool: self.selectionTool, pivotUI: self.pivotUI)

    let toolController = ToolController()
    
    lazy var stageCollector : StageCollector = StageCollector(stage: self.stage, analyzer: self.analyzer) {
        return self.instructionFocus.current === $0 as? InstructionNode
    }

    class DebugRuntimeListener : RuntimeListener {
        
        func runtimeBeginEvaluation(runtime: Runtime, withSize: (Int, Int)) {
            print("begin evaluation")
        }
        
        func runtimeFinishEvaluation(runtime: Runtime) {
            print("finish evaluation")

        }
        
        
        func runtime(runtime: Runtime, didEval: Evaluatable) {
            print("eval instruction")

        }
        
        
        func runtime(runtime: Runtime, exitScopeWithForms forms: [FormIdentifier]) {
            print("exit scope")
            
            for id in forms {
                if let form = runtime.get(id) {
                    print("   draw form \(form)")
                }
            }
        }
        
        
        func runtime(runtime: Runtime, triggeredError: RuntimeError, on onInstruction: Evaluatable) {
            print("Error \(triggeredError)")

        }
        
        
    }
    
    var procedure = Procedure()
    lazy var picture : ReformCore.Picture = ReformCore.Picture(identifier : PictureIdentifier(0), name: "Untiled", size: (580,330), procedure: self.procedure)
    
    lazy var project : Project = Project(pictures: self.picture)
    
    @IBOutlet var canvas : CanvasView?
    
    override func viewDidLoad() {
        toolController.currentTool = scalingTool
        
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

        
        instructionFocus.current = node4
        
        runtime.listeners.append(stageCollector)
        //runtime.listeners.append(DebugRuntimeListener())
        
        
        
        canvas?.toolController = toolController
        
        canvas?.renderers.append(SelectionUIRenderer(selectionUI: selectionUI, stage: stage))

        
        canvas?.renderers.append(SnapUIRenderer(snapUI: snapUI, stage: self.stage))
        
        canvas?.renderers.append(CropUIRenderer(cropUI: cropUI))
        
        
        canvas?.renderers.append(GrabUIRenderer(grabUI: grabUI))
        canvas?.renderers.append(HandleUIRenderer(handleUI: handleUI))
        
        canvas?.renderers.append(PivotUIRenderer(pivotUI: pivotUI))

        if let canvas = canvas {
        
        let trackingOptions : NSTrackingAreaOptions = [.MouseMoved, .EnabledDuringMouseDrag, .ActiveInKeyWindow, .InVisibleRect]
            
            let trackingArea = NSTrackingArea(rect: canvas.bounds, options: trackingOptions, owner: canvas, userInfo: nil)
            
            canvas.addTrackingArea(trackingArea)
            canvas.becomeFirstResponder()

        }
        
        print(instructionFocus.current)
        
        procedureChanged()
        toolController.currentTool.refresh()

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

        if let c = canvas {
            c.shapes = stage.currentShapes
            c.canvasSize = stage.size
            c.needsDisplay = true
        }
    }
    
}