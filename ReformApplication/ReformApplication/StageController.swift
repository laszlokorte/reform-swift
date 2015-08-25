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

struct StageUI {
    let selectionUI : SelectionUI
    let snapUI : SnapUI
    let grabUI : GrabUI
    let handleUI : HandleUI
    let pivotUI : PivotUI
    let cropUI : CropUI

}

@objc
class StageController : NSViewController {

    private var stage : Stage?
    private var analyzer : Analyzer?
    private var runtime : Runtime?
    private var collector : StageCollector?
    private var instructionFocus : InstructionFocus?
    private var toolController : ToolController?
    private var stageUI : StageUI?

    func setup(stage: Stage, analyzer: Analyzer, runtime: Runtime, instructionFocus : InstructionFocus, toolController: ToolController, stageUI : StageUI) {
        self.stage = stage
        self.analyzer = analyzer
        self.runtime = runtime
        self.instructionFocus = instructionFocus
        self.toolController = toolController
        self.stageUI = stageUI

        let collector = StageCollector(stage: stage, analyzer: analyzer) {
            Swift.print("stage colelctor working")
            return instructionFocus.current === $0 as? InstructionNode
        }

        self.collector = collector

        runtime.listeners.append(collector)

        canvas?.toolController = toolController

        canvas?.renderers.append(SelectionUIRenderer(selectionUI: stageUI.selectionUI, stage: stage))


        canvas?.renderers.append(SnapUIRenderer(snapUI: stageUI.snapUI, stage: stage))

        canvas?.renderers.append(CropUIRenderer(cropUI: stageUI.cropUI))


        canvas?.renderers.append(GrabUIRenderer(grabUI: stageUI.grabUI))
        canvas?.renderers.append(HandleUIRenderer(handleUI: stageUI.handleUI))

        canvas?.renderers.append(PivotUIRenderer(pivotUI: stageUI.pivotUI))

        Swift.print("setup")

    }


    @IBOutlet var canvas : CanvasView?
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "procedureChanged", name:"ProcedureChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toolChanged", name:"ToolChanged", object: nil)
        Swift.print("did load")

        if let canvas = canvas {
        
            let trackingOptions : NSTrackingAreaOptions = [.MouseMoved, .EnabledDuringMouseDrag, .ActiveInKeyWindow, .InVisibleRect]
            
            let trackingArea = NSTrackingArea(rect: canvas.bounds, options: trackingOptions, owner: canvas, userInfo: nil)
            
            canvas.addTrackingArea(trackingArea)
        }

    }

    dynamic func procedureChanged() {
        if let stage = stage {
            canvas?.shapes = stage.currentShapes
            canvas?.canvasSize = stage.size
            canvas?.needsDisplay = true
            Swift.print("procedure changed\(stage.size)")
        }
    }

    dynamic func toolChanged() {
        canvas?.needsDisplay = true
    }
    
}