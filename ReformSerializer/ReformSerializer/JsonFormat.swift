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
        return "asd"
    }

    public func decode(string: String) -> NormalizedValue? {
        return .Null
    }
}