//
//  Attribute.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

enum AttributeType {
    case string
    case number
    case pictureId
}

final class Attribute {
    let name : String
    let type : AttributeType
    
    init(name: String, type: AttributeType) {
        self.name = name
        self.type = type
    }
}
