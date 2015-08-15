//
//  CropPoint.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct CropPoint {
    let position : Vec2d
    let offset : CropSide
}

public enum CropSide : Hashable {
    case Top
    case Left
    case Right
    case Bottom
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
}

extension CropPoint : Hashable {
    public var hashValue : Int { return offset.hashValue }
}

public func ==(lhs: CropPoint, rhs: CropPoint) -> Bool {
    return lhs.offset == rhs.offset
}