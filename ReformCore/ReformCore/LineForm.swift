//
//  LineForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics

extension LineForm {
    public enum PointId : ExposedPointIdentifier {
        case start = 0
        case end = 1
        case center = 2
    }
}

final public class LineForm : Form, Creatable {
    public static var stackSize : Int = 4
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.draw
    public var name : String

    
    public init(id: FormIdentifier, name : String) {
        self.identifier = id
        self.name = name
    }
    
    var startPoint : WriteableRuntimePoint {
        get { return StaticPoint(formId: identifier, offset: 0) }
    }
    
    var endPoint : WriteableRuntimePoint {
        get { return StaticPoint(formId: identifier, offset: 2) }
    }
    
    public func initWithRuntime<R:Runtime>(_ runtime: R, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.start.rawValue:ExposedPoint(point: startPoint, name: "Start"),
            PointId.end.rawValue:ExposedPoint(point: endPoint, name: "End"),
            PointId.center.rawValue:ExposedPoint(point: CenterPoint(pointA: startPoint, pointB: endPoint), name: "Center"),
        ]
    }
    
    public var outline : Outline {
        get {
            return LineOutline(start: startPoint, end: endPoint)
        }
    }
}

extension LineForm {
    public var startAnchor : Anchor {
        return StaticPointAnchor(point: startPoint, name: "Start")
    }
    
    public var endAnchor : Anchor {
        return StaticPointAnchor(point: endPoint, name: "End")
    }
}

extension LineForm : Rotatable {
    public var rotator : Rotator {
        get {
            return BasicPointRotator(points: startPoint, endPoint)
        }
    }
}


extension LineForm : Translatable {
    public var translator : Translator {
        get {
            return BasicPointTranslator(points: startPoint, endPoint)
        }
    }
}


extension LineForm : Scalable {
    public var scaler : Scaler {
        get {
            return BasicPointScaler(points: startPoint, endPoint)
        }
    }
}

extension LineForm : Morphable {
    public enum AnchorId : AnchorIdentifier {
        case start = 0
        case end = 1
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.start.rawValue:startAnchor,
            AnchorId.end.rawValue:endAnchor,
        ]
    }
}

extension LineForm : Drawable {
    public func getPathFor<R:Runtime>(_ runtime: R) -> Path? {
        guard
            let start = startAnchor.getPositionFor(runtime),
            let end = endAnchor.getPositionFor(runtime)
            else {
                return nil
        }
        
        return Path(segments: .moveTo(start), .lineTo(end))
    }
    
    public func getShapeFor<R:Runtime>(_ runtime: R) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .pathArea(path), background: .none, stroke: .solid(width: 1, color: ReformGraphics.Color(r:50, g:50, b:50, a: 255)))
    }
}
