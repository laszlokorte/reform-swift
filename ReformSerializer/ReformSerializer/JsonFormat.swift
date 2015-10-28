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

    public func decode(string: String) throws -> NormalizedValue? {
        guard let jsonData: NSData = string.dataUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }

        let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])

        return convert(json)
    }

    func convert(any: AnyObject) -> NormalizedValue? {
        switch any {
        case is NSNull:
            return .Null
        case let v as Bool:
            return .Bool(v)
        case let v as String:
            return .String(v)
        case let v as Int:
            return .Int(v)
        case let v as Double:
            return .Double(v)
        case let v as Array<AnyObject>:
            return .Array(v.flatMap{convert($0)})
        case let v as Dictionary<String, AnyObject>:
            var newDict = [String:NormalizedValue]()
            for (k,v) in v {
                newDict[k] = convert(v)
            }
            return .Dictionary(newDict)

        default:
            return nil
        }
    }
}