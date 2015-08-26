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

    init() {
        self.selectionUI = SelectionUI()
        self.snapUI = SnapUI()
        self.grabUI = GrabUI()
        self.handleUI = HandleUI()
        self.pivotUI = PivotUI()
        self.cropUI = CropUI()
    }
}

@objc
class StageController : NSViewController {

    override var representedObject : AnyObject? {
        didSet {
            if let stageModel = representedObject as? StageViewModel,
                canvas = canvas {
                    configureCanvas(canvas, withStage: stageModel)
            }
        }
    }


    @IBOutlet var canvas : CanvasView? {
        didSet {
            if let stageModel = representedObject as? StageViewModel,
                canvas = canvas {
                    configureCanvas(canvas, withStage: stageModel)
            }
        }
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "procedureChanged", name:"ProcedureEvaluated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toolChanged", name:"ToolChanged", object: nil)

        if let canvas = canvas {
        
            let trackingOptions : NSTrackingAreaOptions = [.MouseMoved, .EnabledDuringMouseDrag, .ActiveInKeyWindow, .InVisibleRect]
            
            let trackingArea = NSTrackingArea(rect: canvas.bounds, options: trackingOptions, owner: canvas, userInfo: nil)
            
            canvas.addTrackingArea(trackingArea)
        }
    }

    func configureCanvas(canvas: CanvasView, withStage stageModel: StageViewModel) {
        canvas.toolController = stageModel.toolController

        canvas.renderers = [
            SelectionUIRenderer(selectionUI: stageModel.stageUI.selectionUI, stage: stageModel.stage),
            SnapUIRenderer(snapUI: stageModel.stageUI.snapUI, stage: stageModel.stage),
            CropUIRenderer(cropUI: stageModel.stageUI.cropUI),
            GrabUIRenderer(grabUI: stageModel.stageUI.grabUI),
            HandleUIRenderer(handleUI: stageModel.stageUI.handleUI),
            PivotUIRenderer(pivotUI: stageModel.stageUI.pivotUI)

        ]
    }

    dynamic func procedureChanged() {
        if let stageModel = representedObject as? StageViewModel {
            canvas?.shapes = stageModel.stage.currentShapes
            canvas?.canvasSize = stageModel.stage.size
            canvas?.needsDisplay = true
        }
    }

    dynamic func toolChanged() {
        canvas?.needsDisplay = true
    }
    
}