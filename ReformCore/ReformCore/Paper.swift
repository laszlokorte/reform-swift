
//
//  Paper.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

extension Paper {
    public enum PointId : ExposedPointIdentifier {
        case topLeft = 0
        case bottomLeft = 1
        case topRight = 2
        case bottomRight = 3
        case top = 4
        case bottom = 5
        case left = 6
        case right = 7
        case center = 8
    }
}

final public class Paper : Form {
    public static var stackSize : Int = 2
    
    public let identifier = FormIdentifier(0)
    
    var width: WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 0)
    }
    
    var height: WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 1)
    }
    
    public func initWithRuntime<R:Runtime>(_ runtime: R, min: Vec2d, max: Vec2d) {
        let delta = max - min
        width.setLengthFor(runtime, length: delta.x)
        height.setLengthFor(runtime, length: delta.y)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.center.rawValue:center,
            
            PointId.top.rawValue:top,
            PointId.left.rawValue:left,
            PointId.right.rawValue:right,
            PointId.bottom.rawValue:bottom,
            
            PointId.topLeft.rawValue:topLeft,
            PointId.topRight.rawValue:topRight,
            PointId.bottomLeft.rawValue:bottomLeft,
            PointId.bottomRight.rawValue:bottomRight,
        ]
    }
    
    public var name : String { get{ return "Canvas" } set{} }
    
    public var outline : Outline {
        return CompositeOutline(parts:
            LineOutline(start: topLeft, end: topRight),
            LineOutline(start: topRight, end: bottomRight),
            LineOutline(start: bottomRight, end: bottomLeft),
            LineOutline(start: bottomLeft, end: topLeft)
        )
    }
}

extension Paper {
    public var top : LabeledPoint {
        return PaperPoint(side: .top, width: width, height: height)
    }
    public var left : LabeledPoint {
        return PaperPoint(side: .left, width: width, height: height)
    }
    public var right : LabeledPoint {
        return PaperPoint(side: .right, width: width, height: height)
    }
    public var bottom : LabeledPoint {
        return PaperPoint(side: .bottom, width: width, height: height)
    }
    
    
    public var topLeft : LabeledPoint {
        return PaperPoint(side: .topLeft, width: width, height: height)
    }
    public var bottomLeft : LabeledPoint {
        return PaperPoint(side: .bottomLeft, width: width, height: height)
    }
    public var topRight : LabeledPoint {
        return PaperPoint(side: .topRight, width: width, height: height)
    }
    public var bottomRight : LabeledPoint {
        return PaperPoint(side: .bottomRight, width: width, height: height)
    }
    public var center : LabeledPoint {
        return PaperPoint(side: .center, width: width, height: height)
    }
}

extension Paper.PointId {
    
    var x : Double {
        switch self {
        case left, topLeft, bottomLeft:
            return 0
        case right, topRight, bottomRight:
            return 1
        case top, bottom, center:
            return  0.5
        }
    }
    
    var y : Double {
        switch self {
        case top, topLeft, topRight:
            return 0
        case bottom, bottomLeft, bottomRight:
            return 1
        case left, right, center:
            return 0.5
        }
    }
    
    var name : String {
        switch self {
        case .top: return "Top"
        case .right: return "Right"
        case .left: return "Left"
        case .bottom: return "Bottom"
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        case .center: return "Center"
        }
    }
}

struct PaperPoint : RuntimePoint, Labeled {
    let side : Paper.PointId
    let width : RuntimeLength
    let height : RuntimeLength
    
    init(side: Paper.PointId, width: RuntimeLength, height: RuntimeLength) {
        self.side = side
        self.width = width
        self.height = height
    }
    
    func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            w = width.getLengthFor(runtime),
            h = height.getLengthFor(runtime) else {
            return nil
        }
        return Vec2d(x: side.x * w, y:side.y * h)
    }
    func getDescription(_ stringifier: Stringifier) -> String {
        return "Canvas' \(side.name)"
    }
}

extension PaperPoint : Equatable {

}

func ==(lhs: PaperPoint, rhs: PaperPoint) -> Bool {
    return lhs.side == rhs.side
}

