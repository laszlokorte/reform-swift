//
//  ExpressionLexer.swift
//  Reform
//
//  Created by Laszlo Korte on 10.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

var lexerGenerator = LexerGenerator<ShuntingYardTokenType>() { (inout conf : LexerGenerator<ShuntingYardTokenType>) in

    conf.ignore("\\s+")
    conf.ignore("\\u00A0+")

    conf.add(.ParenthesisLeft, pattern: "\\(")
    conf.add(.ParenthesisRight, pattern: "\\)")


    conf.add(.Operator, pattern: "\\-")
    conf.add(.Operator, pattern: "\\+")
    conf.add(.Operator, pattern: "\\/")
    conf.add(.Operator, pattern: "\\*")
    conf.add(.Operator, pattern: "\\%")
    conf.add(.Operator, pattern: "\\^")


    conf.add(.Operator, pattern: "~")
    conf.add(.Operator, pattern: "\\&\\&")
    conf.add(.Operator, pattern: "\\|\\|")


    conf.add(.Operator, pattern: "<")
    conf.add(.Operator, pattern: "<=")
    conf.add(.Operator, pattern: ">")
    conf.add(.Operator, pattern: ">=")

    conf.add(.Operator, pattern: "==")

    conf.add(.ArgumentSeparator, pattern: ",")
    conf.add(.LiteralValue, pattern: "(0|([1-9][0-9]*))(\\.[0-9]*)?")
    conf.add(.LiteralValue, pattern: "#[0-9a-fA-F]{6,8}")
    conf.add(.LiteralValue, pattern: "\"[^\"]+\"")
    conf.add(.LiteralValue, pattern: "(true|false)")
    conf.add(.Identifier, pattern: "[a-zA-Z_][_a-zA-Z0-9]*")
    conf.add(.LiteralValue, pattern: "\"[^\"]*\"")


}
