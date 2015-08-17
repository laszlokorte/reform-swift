
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
        case TopLeft = 0
        case BottomLeft = 1
        case TopRight = 2
        case BottomRight = 3
        case Top = 4
        case Bottom = 5
        case Left = 6
        case Right = 7
        case Center = 8
    }
}

public class Paper : Form {
    public static var stackSize : Int = 2
    
    public let identifier = FormIdentifier(0)
    
    var width: WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 0)
    }
    
    var height: WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 1)
    }
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        let delta = max - min
        width.setLengthFor(runtime, length: delta.x)
        height.setLengthFor(runtime, length: delta.y)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.Center.rawValue:center,
            
            PointId.Top.rawValue:top,
            PointId.Left.rawValue:left,
            PointId.Right.rawValue:right,
            PointId.Bottom.rawValue:bottom,
            
            PointId.TopLeft.rawValue:topLeft,
            PointId.TopRight.rawValue:topRight,
            PointId.BottomLeft.rawValue:bottomLeft,
            PointId.BottomRight.rawValue:bottomRight,
        ]
    }
    
    public var name : String { get{ return "Canvas" } set{} }
    
    public var outline : Outline {
        return NullOutline()
    }
}

extension Paper {
    var top : LabeledPoint {
        return PaperPoint(side: .Top, width: width, height: height)
    }
    var left : LabeledPoint {
        return PaperPoint(side: .Left, width: width, height: height)
    }
    var right : LabeledPoint {
        return PaperPoint(side: .Right, width: width, height: height)
    }
    var bottom : LabeledPoint {
        return PaperPoint(side: .Bottom, width: width, height: height)
    }
    
    
    var topLeft : LabeledPoint {
        return PaperPoint(side: .TopLeft, width: width, height: height)
    }
    var bottomLeft : LabeledPoint {
        return PaperPoint(side: .BottomLeft, width: width, height: height)
    }
    var topRight : LabeledPoint {
        return PaperPoint(side: .TopRight, width: width, height: height)
    }
    var bottomRight : LabeledPoint {
        return PaperPoint(side: .BottomRight, width: width, height: height)
    }
    var center : LabeledPoint {
        return PaperPoint(side: .Center, width: width, height: height)
    }
}

extension Paper.PointId {
    
    var x : Double {
        switch self {
        case Left, TopLeft, BottomLeft:
            return 0
        case Right, TopRight, BottomRight:
            return 1
        case Top, Bottom, Center:
            return  0.5
        }
    }
    
    var y : Double {
        switch self {
        case Top, TopLeft, TopRight:
            return 0
        case Bottom, BottomLeft, BottomRight:
            return 1
        case Left, Right, Center:
            return 0.5
        }
    }
    
    var name : String {
        switch self {
        case .Top: return "Top"
        case .Right: return "Right"
        case .Left: return "Left"
        case .Bottom: return "Bottom"
        case .TopLeft: return "Top Left"
        case .TopRight: return "Top Right"
        case .BottomLeft: return "Bottom Left"
        case .BottomRight: return "Bottom Right"
        case .Center: return "Center"
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
    
    func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let w = width.getLengthFor(runtime),
            let h = height.getLengthFor(runtime) else {
            return nil
        }
        return Vec2d(x: side.x * w, y:side.y * h)
    }
    func getDescription(analyzer: Analyzer) -> String {
        return "Canvas' \(side.name)"
    }
}