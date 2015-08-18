//
//  Handle.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

public typealias PivotPair = (EntityPoint, EntityPoint)

public struct Handle {
    public let formId : FormIdentifier
    public let anchorId : AnchorIdentifier
    
    public let label : String
    public let position : Vec2d
    
    public let defaultPivot : PivotPair
}


extension Handle : Hashable {
    public var hashValue : Int { return formId.hashValue * 13 + anchorId.hashValue }
}

public func ==(lhs: Handle, rhs: Handle) -> Bool {
    return lhs.formId == rhs.formId && lhs.anchorId == rhs.anchorId
}

