//
//  ProcedureViewModel.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformTools

final class ProcedureViewModel {
    let analyzer : DefaultAnalyzer
    let instructionFocus : InstructionFocus
    let snapshotCollector : SnapshotCollector
    let instructionFocusChanger : InstructionFocusChanger
    let instructionChanger : () -> ()
    let formSelection : FormSelection

    init(analyzer: DefaultAnalyzer, instructionFocus : InstructionFocus, snapshotCollector : SnapshotCollector, instructionFocusChanger : InstructionFocusChanger, formSelection: FormSelection, instructionChanger : () -> ()) {
        self.analyzer = analyzer
        self.instructionFocus = instructionFocus
        self.snapshotCollector = snapshotCollector
        self.instructionFocusChanger = instructionFocusChanger
        self.instructionChanger = instructionChanger
        self.formSelection = formSelection
    }
}