//
//  ProcedureViewModel.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformTools

class ProcedureViewModel {
    let analyzer : DefaultAnalyzer
    let instructionFocus : InstructionFocus

    init(analyzer: DefaultAnalyzer, instructionFocus : InstructionFocus) {
        self.analyzer = analyzer
        self.instructionFocus = instructionFocus
    }
}