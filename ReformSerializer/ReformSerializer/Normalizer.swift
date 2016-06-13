//
//  Normalizer.swift
//  ReformSerializer
//
//  Created by Laszlo Korte on 31.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum InitialisationError : ErrorProtocol {
    case unknown
}

public enum NormalizationError : ErrorProtocol {
    case notNormalizable(Any.Type)
}

public enum NormalizedValue {
    case null
    case bool(Swift.Bool)
    case string(Swift.String)
    case int(Swift.Int)
    case double(Swift.Double)
    case array([NormalizedValue])
    case dictionary([Swift.String:NormalizedValue])
}

public protocol Normalizable {
    func normalize() throws -> NormalizedValue

    init(normalizedValue: NormalizedValue) throws
}

