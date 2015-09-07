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
    let camera: Camera

    init(stage: Stage, stageUI: StageUI, toolController : ToolController, camera: Camera) {
        self.stage = stage
        self.stageUI = stageUI
        self.toolController = toolController
        self.camera = camera
    }
}