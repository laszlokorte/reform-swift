//
//  CropPoint.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct CropPoint {
    public let position : Vec2d
    public let offset : CropSide

    public init(position: Vec2d, offset: CropSide) {
        self.position = position
        self.offset = offset
    }
}

extension CropPoint {
    public var isCorner : Bool {
        return offset.vector.x != 0 && offset.vector.y != 0
    }
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

    public var vector : Vec2d {
        switch self {
        case .Top: return Vec2d(x: 0,y: 1)
        case .Left: return Vec2d(x: -1,y: 0)
        case .Right: return Vec2d(x: 1,y: 0)
        case .Bottom: return Vec2d(x: 0,y: -1)
        case .TopLeft: return Vec2d(x: -1,y: 1)
        case .TopRight: return Vec2d(x: 1,y: 1)
        case .BottomLeft: return Vec2d(x: -1,y: -1)
        case .BottomRight: return Vec2d(x: 1,y: -1)
        }
    }
}

extension CropPoint : Hashable {
    public var hashValue : Int { return offset.hashValue }
}

public func ==(lhs: CropPoint, rhs: CropPoint) -> Bool {
    return lhs.offset == rhs.offset
}