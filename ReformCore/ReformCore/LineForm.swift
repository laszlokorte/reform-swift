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
        case Start = 0
        case End = 1
        case Center = 2
    }
}

final public class LineForm : Form{
    public static var stackSize : Int = 4
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.Draw
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
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.Start.rawValue:ExposedPoint(point: startPoint, name: "Start"),
            PointId.End.rawValue:ExposedPoint(point: endPoint, name: "End"),
            PointId.Center.rawValue:ExposedPoint(point: CenterPoint(pointA: startPoint, pointB: endPoint), name: "Center"),
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
        case Start = 0
        case End = 1
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.Start.rawValue:startAnchor,
            AnchorId.End.rawValue:endAnchor,
        ]
    }
}

extension LineForm : Drawable {
    public func getPathFor(runtime: Runtime) -> Path? {
        guard
            let start = startAnchor.getPositionFor(runtime),
            let end = endAnchor.getPositionFor(runtime)
            else {
                return nil
        }
        
        return Path(segments: .MoveTo(start), .LineTo(end))
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .PathArea(path), background: .None, stroke: .Solid(width: 1, color: Color(r:50, g:50, b:50, a: 255)))
    }
}
