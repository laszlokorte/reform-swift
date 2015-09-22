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
    let maskUI : MaskUI

    init() {
        self.selectionUI = SelectionUI()
        self.snapUI = SnapUI()
        self.grabUI = GrabUI()
        self.handleUI = HandleUI()
        self.pivotUI = PivotUI()
        self.cropUI = CropUI()
        self.maskUI = MaskUI()
    }
}

@objc
final class StageController : NSViewController {
    var toolController : ToolController?
    var stageRenderer : StageRenderer?
    var selection : FormSelection?
    var stage : Stage?

    override var representedObject : AnyObject? {
        didSet {
            if let stageModel = representedObject as? StageViewModel,
                canvas = canvas {
                    configureCanvas(canvas, withStage: stageModel)
                selection = stageModel.selection
                stage = stageModel.stage
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
            
            let trackingArea = NSTrackingArea(rect: canvas.bounds, options: trackingOptions, owner: self, userInfo: nil)
            
            canvas.addTrackingArea(trackingArea)
        }
    }

    func configureCanvas(canvas: CanvasView, withStage stageModel: StageViewModel) {
        toolController = stageModel.toolController

        let sr = StageRenderer(stage: stageModel.stage)
        stageRenderer = sr

        canvas.camera = stageModel.camera
        canvas.renderers = [
            MaskUIRenderer(maskUI: stageModel.stageUI.maskUI),
            sr,
            SelectionUIRenderer(selectionUI: stageModel.stageUI.selectionUI, stage: stageModel.stage, camera: stageModel.camera),
            SnapUIRenderer(snapUI: stageModel.stageUI.snapUI, stage: stageModel.stage, camera: stageModel.camera),
            CropUIRenderer(stage: stageModel.stage, cropUI: stageModel.stageUI.cropUI, camera: stageModel.camera),
            GrabUIRenderer(grabUI: stageModel.stageUI.grabUI, camera: stageModel.camera),
            HandleUIRenderer(handleUI: stageModel.stageUI.handleUI, camera: stageModel.camera),
            PivotUIRenderer(pivotUI: stageModel.stageUI.pivotUI, camera: stageModel.camera)

        ]
    }

    dynamic func procedureChanged() {
        if let stageModel = representedObject as? StageViewModel {
            canvas?.canvasSize = stageModel.stage.size
            canvas?.needsDisplay = true
        }
    }

    dynamic func toolChanged() {
        canvas?.needsDisplay = true
    }

    private func fromEvent(event: NSEvent) -> Vec2d? {
        return fromPoint(event.locationInWindow)
    }

    private func fromPoint(point: NSPoint) -> Vec2d? {
        guard let canvas = canvas else {
            return nil
        }

        let pos = canvas.convertPoint(point, fromView: nil)

        let offsetX = (canvas.bounds.width-CGFloat(canvas.canvasSize.x))/2.0
        let offsetY = (canvas.bounds.height-CGFloat(canvas.canvasSize.y))/2.0


        return Vec2d(x: Double(pos.x-offsetX), y: Double(pos.y-offsetY))
    }

    override func mouseDown(theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }

        toolController?.process(.Press, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func mouseUp(theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }


        toolController?.process(.Release, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func mouseMoved(theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }

        toolController?.process(.Move, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func mouseDragged(theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }


        toolController?.process(.Move, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func flagsChanged(theEvent: NSEvent) {
        guard let mousePostion = canvas?.window?.mouseLocationOutsideOfEventStream else {
            return
        }
        guard let pos = fromPoint(mousePostion) else { return }

        toolController?.process(.ModifierChange, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func keyDown(theEvent: NSEvent) {
        guard let mousePostion = canvas?.window?.mouseLocationOutsideOfEventStream else {
            return
        }
        guard let pos = fromPoint(mousePostion) else { return }


        if theEvent.keyCode == 49 {
            stageRenderer?.lookIntoFuture = true
        } else if theEvent.keyCode == 13 /*W*/ {
            toolController?.process(.Toggle, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else if theEvent.keyCode == 53 /*ESC*/ {
            toolController?.cancel()
        } else if theEvent.keyCode == 48 || theEvent.keyCode == 50 /*TAB*/ {
            toolController?.process(.Cycle, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else if !theEvent.modifierFlags.isEmpty {
            toolController?.process(.ModifierChange, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else {
            super.keyDown(theEvent)
            return
        }
        canvas?.needsDisplay = true
    }

    override func keyUp(theEvent: NSEvent) {
        guard let mousePostion = canvas?.window?.mouseLocationOutsideOfEventStream else {
            return
        }
        guard let pos = fromPoint(mousePostion) else { return }


        if theEvent.keyCode == 49 {
            stageRenderer?.lookIntoFuture = false
        } else if !theEvent.modifierFlags.isEmpty {
            toolController?.process(.ModifierChange, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else {
            super.keyUp(theEvent)
            return
        }
        canvas?.needsDisplay = true
    }

    override func selectAll(sender: AnyObject?) {
        if let stage = stage {
            selection?.select(Set(stage.entities.lazy.filter{$0.hitArea != HitArea.None}.map{$0.id}))
        }
        canvas?.needsDisplay = true
    }

}