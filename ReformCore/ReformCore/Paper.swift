//
//  Paper.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

class Paper : Form {
    static var stackSize : Int = 2
    
    let identifier = FormIdentifier(0)
    
    var width: WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 0)
    }
    
    var height: WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 1)
    }
    
    func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        let delta = max - min
        width.setLengthFor(runtime, length: delta.x)
        height.setLengthFor(runtime, length: delta.y)
    }
    
    func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            ExposedPointIdentifier(0):center,
            
            ExposedPointIdentifier(1):top,
            ExposedPointIdentifier(2):left,
            ExposedPointIdentifier(3):right,
            ExposedPointIdentifier(4):bottom,
            
            ExposedPointIdentifier(5):topLeft,
            ExposedPointIdentifier(6):topRight,
            ExposedPointIdentifier(7):bottomLeft,
            ExposedPointIdentifier(8):bottomRight,
        ]
    }
    
    var name : String { get{ return "Canvas" } set{} }
    
    var outline : Outline {
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

struct PaperPoint : RuntimePoint, Labeled {
    enum Side {
        case Left
        case Right
        case Top
        case Bottom
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
        case Center
        
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
    
    let side : Side
    let width : RuntimeLength
    let height : RuntimeLength
    
    init(side: Side, width: RuntimeLength, height: RuntimeLength) {
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