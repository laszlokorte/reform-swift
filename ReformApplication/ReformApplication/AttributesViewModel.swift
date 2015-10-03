//
//  AttributesViewModel.swift
//  Reform
//
//  Created by Laszlo Korte on 02.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformTools
import ReformCore
import ReformStage

class AttributesViewModel {
    let stage : Stage
    let selection : FormSelection
    let analyzer : Analyzer

    init(stage : Stage, selection : FormSelection, analyzer: Analyzer) {
        self.stage = stage
        self.selection = selection
        self.analyzer = analyzer
    }
}