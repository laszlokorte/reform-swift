//
//  JsonFormat.swift
//  ReformSerializer
//
//  Created by Laszlo Korte on 31.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final public class JsonFormat : Encoder, Decoder {
    public init() {}

    public func encode(value: NormalizedValue) -> String {
        switch value {
        case .Null:
            return "null"
        case .Bool(let b):
            return b ? "true" : "false"
        case .String(let s):
            return "\"\(s)\""
        case .Int(let i):
            return String(i)
        case .Double(let d):
            return String(format: "%f", d)
        case .Array(let arr):
            return String(format: "[%@]", arr.map({ encode($0) }).joinWithSeparator(","))
        case .Dictionary(let dict):
            return String(format: "{%@}", dict.map({ (k,v) in return "\"\(k)\":\(encode(v))" }).joinWithSeparator(","))
        }
    }

    public func decode(string: String) -> NormalizedValue? {
        return .Null
    }
}