//
//  Decoder.swift
//  ReformSerializer
//
//  Created by Laszlo Korte on 31.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

protocol Decoder {
    func decode(_ string: String) throws -> NormalizedValue?
}
