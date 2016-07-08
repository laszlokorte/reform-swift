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
    let affineHandleUI : AffineHandleUI
    let pivotUI : PivotUI
    let cropUI : CropUI
    let maskUI : MaskUI

    init() {
        self.selectionUI = SelectionUI()
        self.snapUI = SnapUI()
        self.grabUI = GrabUI()
        self.handleUI = HandleUI()
        self.affineHandleUI = AffineHandleUI()
        self.pivotUI = PivotUI()
        self.cropUI = CropUI()
        self.maskUI = MaskUI()
    }
}

@objc
final class StageController : NSViewController {
    var toolController : ToolController?
    var stageRenderer : StageRenderer?
    var selectionRenderer : SelectionUIRenderer?
    var selection : FormSelection?
    var stage : Stage?
    var selectionChanger : FormSelectionChanger?

    override var representedObject : AnyObject? {
        didSet {
            if let stageModel = representedObject as? StageViewModel,
                canvas = canvas {
                    configureCanvas(canvas, withStage: stageModel)
                selection = stageModel.selection
                stage = stageModel.stage
                selectionChanger = stageModel.selectionChanger
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

    override func viewDidAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(StageController.procedureChanged), name:NSNotification.Name("ProcedureEvaluated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StageController.toolChanged), name:NSNotification.Name("ToolChanged"), object: nil)
    }

    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name("ProcedureEvaluated"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name("ToolChanged"), object: nil)
    }
    
    override func viewDidLoad() {
        if let canvas = canvas {
        
            let trackingOptions : NSTrackingAreaOptions = [.mouseMoved, .enabledDuringMouseDrag, .activeInKeyWindow, .inVisibleRect]
            
            let trackingArea = NSTrackingArea(rect: canvas.bounds, options: trackingOptions, owner: self, userInfo: nil)
            
            canvas.addTrackingArea(trackingArea)
        }
    }

    func configureCanvas(_ canvas: CanvasView, withStage stageModel: StageViewModel) {
        toolController = stageModel.toolController

        let sr = StageRenderer(stage: stageModel.stage, camera: stageModel.camera, maskUI: stageModel.stageUI.maskUI)
        stageRenderer = sr
        let slr = SelectionUIRenderer(selectionUI: stageModel.stageUI.selectionUI, stage: stageModel.stage, camera: stageModel.camera)
        selectionRenderer = slr

        canvas.camera = stageModel.camera
        canvas.renderers = [
            MaskUIRenderer(maskUI: stageModel.stageUI.maskUI),
            sr,
            slr,
            SnapUIRenderer(snapUI: stageModel.stageUI.snapUI, stage: stageModel.stage, camera: stageModel.camera),
            CropUIRenderer(stage: stageModel.stage, cropUI: stageModel.stageUI.cropUI, camera: stageModel.camera),
            GrabUIRenderer(grabUI: stageModel.stageUI.grabUI, camera: stageModel.camera),
            HandleUIRenderer(handleUI: stageModel.stageUI.handleUI, camera: stageModel.camera),
            AffineHandleUIRenderer(affineHandleUI: stageModel.stageUI.affineHandleUI, camera: stageModel.camera),
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

    private func fromEvent(_ event: NSEvent) -> Vec2d? {
        return fromPoint(event.locationInWindow)
    }

    private func fromPoint(_ point: NSPoint) -> Vec2d? {
        guard let canvas = canvas else {
            return nil
        }

        let pos = canvas.convert(point, from: nil)

        let offsetX = (canvas.bounds.width-CGFloat(canvas.canvasSize.x))/2.0
        let offsetY = (canvas.bounds.height-CGFloat(canvas.canvasSize.y))/2.0


        return Vec2d(x: Double(pos.x-offsetX), y: Double(pos.y-offsetY))
    }

    override func mouseDown(_ theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }

        toolController?.process(.press, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func mouseUp(_ theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }


        toolController?.process(.release, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func mouseMoved(_ theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }

        toolController?.process(.move, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func mouseDragged(_ theEvent: NSEvent) {
        guard let pos = fromEvent(theEvent) else { return }


        toolController?.process(.move, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func flagsChanged(_ theEvent: NSEvent) {
        guard let mousePostion = canvas?.window?.mouseLocationOutsideOfEventStream else {
            return
        }
        guard let pos = fromPoint(mousePostion) else { return }

        toolController?.process(.modifierChange, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))

        canvas?.needsDisplay = true
    }

    override func keyDown(_ theEvent: NSEvent) {
        guard let mousePostion = canvas?.window?.mouseLocationOutsideOfEventStream else {
            return
        }
        guard let pos = fromPoint(mousePostion) else { return }


        if theEvent.keyCode == 49 {
            stageRenderer?.lookIntoFuture = true
            selectionRenderer?.lookIntoFuture = true
        } else if theEvent.keyCode == 13 /*W*/ {
            toolController?.process(.toggle, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else if theEvent.keyCode == 53 /*ESC*/ {
            toolController?.cancel()
        } else if theEvent.keyCode == 48 || theEvent.keyCode == 50 /*TAB*/ {
            toolController?.process(.cycle, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else if !theEvent.modifierFlags.isEmpty {
            toolController?.process(.modifierChange, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else {
            super.keyDown(theEvent)
            return
        }
        canvas?.needsDisplay = true
    }

    override func keyUp(_ theEvent: NSEvent) {
        guard let mousePostion = canvas?.window?.mouseLocationOutsideOfEventStream else {
            return
        }
        guard let pos = fromPoint(mousePostion) else { return }


        if theEvent.keyCode == 49 {
            stageRenderer?.lookIntoFuture = false
            selectionRenderer?.lookIntoFuture = false
        } else if !theEvent.modifierFlags.isEmpty {
            toolController?.process(.modifierChange, atPosition: pos, withModifier: Modifier.fromEvent(theEvent))
        } else {
            super.keyUp(theEvent)
            return
        }
        canvas?.needsDisplay = true
    }

    override func selectAll(_ sender: AnyObject?) {
        if let stage = stage {
            selectionChanger?.setSelection(Set(stage.entities.lazy.filter{$0.hitArea != HitArea.none}.map{$0.id.runtimeId}))
        }
        canvas?.needsDisplay = true
    }

}
