//
//  ProcedureViewModel.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformExpression
import ReformTools

final class ProcedureViewModel {
    let analyzer : DefaultAnalyzer
    let instructionFocus : InstructionFocus
    let snapshotCollector : SnapshotCollector
    let instructionFocusChanger : InstructionFocusChanger
    let instructionChanger : () -> ()
    let formSelection : FormSelection
    let formIdSequence : IdentifierSequence<FormIdentifier>
    let nameAllocator : NameAllocator
    let lexer : Lexer<ShuntingYardTokenType>
    let parser : ShuntingYardParser<ExpressionParserDelegate>

    init(analyzer: DefaultAnalyzer, instructionFocus : InstructionFocus, snapshotCollector : SnapshotCollector, instructionFocusChanger : InstructionFocusChanger, formSelection: FormSelection, formIdSequence: IdentifierSequence<FormIdentifier>, nameAllocator: NameAllocator,
        lexer : Lexer<ShuntingYardTokenType>,
        parser: ShuntingYardParser<ExpressionParserDelegate>,
        instructionChanger : @escaping () -> ()) {
        self.analyzer = analyzer
        self.instructionFocus = instructionFocus
        self.snapshotCollector = snapshotCollector
        self.instructionFocusChanger = instructionFocusChanger
        self.instructionChanger = instructionChanger
        self.formSelection = formSelection
        self.nameAllocator = nameAllocator
        self.formIdSequence = formIdSequence
        self.lexer = lexer
        self.parser = parser
    }
}
