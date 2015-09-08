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
    public let pointId : ExposedPointIdentifier
    
    public let label : String
    public let position : Vec2d
}

public struct AffineHandle {
    public let handle : Handle
    public let defaultPivot : PivotPair
    public let scaleAxis : ScaleAxis
}

extension Handle {
    public var runtimePoint : LabeledPoint {
        return ForeignFormPoint(formId: formId, pointId: pointId)
    }
}


extension Handle : Hashable {
    public var hashValue : Int { return formId.hashValue * 13 + anchorId.hashValue }
}

public func ==(lhs: Handle, rhs: Handle) -> Bool {
    return lhs.formId == rhs.formId && lhs.anchorId == rhs.anchorId
}

extension AffineHandle {
    public var runtimePoint : LabeledPoint {
        return handle.runtimePoint
    }
}


extension AffineHandle : Hashable {
    public var hashValue : Int { return handle.hashValue }
}

public func ==(lhs: AffineHandle, rhs: AffineHandle) -> Bool {
    return lhs.handle == rhs.handle
}

