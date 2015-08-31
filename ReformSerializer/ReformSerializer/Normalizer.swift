//
//  Normalizer.swift
//  ReformSerializer
//
//  Created by Laszlo Korte on 31.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

enum InitialisationError : ErrorType {
    case Unknown
}

enum NormalizationError : ErrorType {
    case NotNormalizable(Any.Type)
}

enum NormalizedValue {
    case Null
    case Bool(Swift.Bool)
    case String(Swift.String)
    case Int(Swift.Int)
    case Double(Swift.Double)
    case Array([NormalizedValue])
    case Dictionary([Swift.String:NormalizedValue])
}

protocol Normalizable {
    func normalize() throws -> NormalizedValue

    init(normalizedValue: NormalizedValue) throws
}

