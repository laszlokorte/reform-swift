//
//  JsonFormat.swift
//  ReformSerializer
//
//  Created by Laszlo Korte on 31.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final class JsonFormat : Encoder, Decoder {
    func encode(value: NormalizedValue) -> String {
        return ""
    }

    func decode(string: String) -> NormalizedValue? {
        return .Null
    }
}