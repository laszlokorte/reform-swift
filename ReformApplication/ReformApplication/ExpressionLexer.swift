//
//  ExpressionLexer.swift
//  Reform
//
//  Created by Laszlo Korte on 10.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

var lexerGenerator = LexerGenerator<ShuntingYardTokenType>() { (conf : inout LexerGenerator<ShuntingYardTokenType>) in

    conf.ignore("\\s+")
    conf.ignore("\\u00A0+")

    conf.add(.parenthesisLeft, pattern: "\\(")
    conf.add(.parenthesisRight, pattern: "\\)")


    conf.add(.operator, pattern: "\\-")
    conf.add(.operator, pattern: "\\+")
    conf.add(.operator, pattern: "\\/")
    conf.add(.operator, pattern: "\\*")
    conf.add(.operator, pattern: "\\%")
    conf.add(.operator, pattern: "\\^")


    conf.add(.operator, pattern: "~")
    conf.add(.operator, pattern: "\\&\\&")
    conf.add(.operator, pattern: "\\|\\|")


    conf.add(.operator, pattern: "<")
    conf.add(.operator, pattern: "<=")
    conf.add(.operator, pattern: ">")
    conf.add(.operator, pattern: ">=")

    conf.add(.operator, pattern: "==")

    conf.add(.argumentSeparator, pattern: ",")
    conf.add(.literalValue, pattern: "(0|([1-9][0-9]*))(\\.[0-9]*)?")
    conf.add(.literalValue, pattern: "#[0-9a-fA-F]{6,8}")
    conf.add(.literalValue, pattern: "\"[^\"]+\"")
    conf.add(.literalValue, pattern: "(true|false)")
    conf.add(.identifier, pattern: "[a-zA-Z_][_a-zA-Z0-9]*")
    conf.add(.literalValue, pattern: "\"[^\"]*\"")


}
