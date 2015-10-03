//
//  StageViewModel.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage
import ReformTools

final class StageViewModel {
    let stage : Stage
    let stageUI : StageUI
    let toolController : ToolController
    let selection : FormSelection
    let camera: Camera
    let selectionChanger : FormSelectionChanger

    init(stage: Stage, stageUI: StageUI, toolController : ToolController, selection: FormSelection, camera: Camera, selectionChanger: FormSelectionChanger) {
        self.stage = stage
        self.stageUI = stageUI
        self.toolController = toolController
        self.selection = selection
        self.camera = camera
        self.selectionChanger = selectionChanger
    }
}