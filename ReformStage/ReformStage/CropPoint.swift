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
    case top
    case left
    case right
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    public var vector : Vec2d {
        switch self {
        case .top: return Vec2d(x: 0,y: 1)
        case .left: return Vec2d(x: -1,y: 0)
        case .right: return Vec2d(x: 1,y: 0)
        case .bottom: return Vec2d(x: 0,y: -1)
        case .topLeft: return Vec2d(x: -1,y: 1)
        case .topRight: return Vec2d(x: 1,y: 1)
        case .bottomLeft: return Vec2d(x: -1,y: -1)
        case .bottomRight: return Vec2d(x: 1,y: -1)
        }
    }
}

extension CropPoint : Hashable {
    public var hashValue : Int { return offset.hashValue }
}

public func ==(lhs: CropPoint, rhs: CropPoint) -> Bool {
    return lhs.offset == rhs.offset
}
