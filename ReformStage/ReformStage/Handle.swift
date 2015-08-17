//
//  Handle.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

typealias PivotPair = (EntityPoint, EntityPoint)

public struct Handle {
    let formId : FormIdentifier
    let anchorId : AnchorIdentifier
    
    let label : String
    let position : Vec2d
    
    let defaultPivot : PivotPair
}


extension Handle : Hashable {
    public var hashValue : Int { return formId.hashValue * 13 + anchorId.hashValue }
}

public func ==(lhs: Handle, rhs: Handle) -> Bool {
    return lhs.formId == rhs.formId && lhs.anchorId == rhs.anchorId
}

