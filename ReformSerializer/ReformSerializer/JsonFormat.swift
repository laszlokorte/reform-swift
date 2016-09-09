//
//  JsonFormat.swift
//  ReformSerializer
//
//  Created by Laszlo Korte on 31.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final public class JsonFormat : Encoder, Decoder {
    public init() {}

    public func encode(_ value: NormalizedValue) -> String {
        switch value {
        case .null:
            return "null"
        case .bool(let b):
            return b ? "true" : "false"
        case .string(let s):
            return "\"\(s)\""
        case .int(let i):
            return String(i)
        case .double(let d):
            return String(format: "%f", d)
        case .array(let arr):
            return String(format: "[%@]", arr.map({ encode($0) }).joined(separator: ","))
        case .dictionary(let dict):
            return String(format: "{%@}", dict.map({ (k,v) in return "\"\(k)\":\(encode(v))" }).joined(separator: ","))
        }
    }

    public func decode(_ string: String) throws -> NormalizedValue? {
        guard let jsonData: Data = string.data(using: String.Encoding.utf8) else {
            return nil
        }

        let json = try JSONSerialization.jsonObject(with: jsonData, options: [])

        return convert(json)
    }

    func convert(_ any: Any) -> NormalizedValue? {
        switch any {
        case is NSNull:
            return .null
        case let v as Bool:
            return .bool(v)
        case let v as String:
            return .string(v)
        case let v as Int:
            return .int(v)
        case let v as Double:
            return .double(v)
        case let v as Array<Any>:
            return .array(v.flatMap{convert($0)})
        case let v as Dictionary<String, Any>:
            var newDict = [String:NormalizedValue]()
            for (k,v) in v {
                newDict[k] = convert(v)
            }
            return .dictionary(newDict)

        default:
            return nil
        }
    }
}
