//
//  ArcForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics


extension ArcForm {
    
    public enum PointId : ExposedPointIdentifier {
        case Start = 0
        case End = 1
        case Center = 2
    }
}

final public class ArcForm : Form, Creatable {
    public static var stackSize : Int = 5
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.Draw
    public var name : String
    
    
    public init(id formId: FormIdentifier, name : String) {
        self.identifier = formId
        self.name = name
    }
    
    public var startPoint : WriteableRuntimePoint {
        return StaticPoint(formId: identifier, offset: 0)
    }
    
    public var endPoint : WriteableRuntimePoint {
        return StaticPoint(formId: identifier, offset: 2)
    }
    
    public var offset : WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 4)
    }
    
    public func initWithRuntime<R:Runtime>(runtime: R, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
        offset.setLengthFor(runtime, length: 50)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.Start.rawValue:ExposedPoint(point: startPoint, name: "Start"),
            PointId.End.rawValue:ExposedPoint(point: endPoint, name: "End"),
            PointId.Center.rawValue:ExposedPoint(point: centerPoint, name: "Center"),
        ]
    }
    
    public var outline : Outline {
        return CompositeOutline(parts:
            LineOutline(start: endPoint, end: startPoint),
            ArcOutline(center: centerPoint, radius: PointLength(pointA: startPoint, pointB: centerPoint), angleA: PointAngle(center: centerPoint, point: startPoint), angleB: PointAngle(center: centerPoint, point: endPoint))
        )
    }
}

extension ArcForm : Rotatable {
    
    public var rotator : Rotator {
        return BasicPointRotator(points: startPoint, endPoint)
    }
    
}

extension ArcForm : Translatable {
    
    public var translator : Translator {
        return BasicPointTranslator(points: startPoint, endPoint)
    }
}

extension ArcForm : Scalable {
    
    public var scaler : Scaler {
        return CompositeScaler(scalers:
            BasicPointScaler(points: startPoint, endPoint),
            AbsoluteScaler(scaler: BasicLengthScaler(length: offset, angle: ConstantAngle()))
        )
    }
    
}

extension ArcForm {
    var controlAnchor : Anchor {
        return OrthogonalOffsetAnchor(name: "Control Point", pointA: startPoint, pointB: endPoint, offset: offset)
    }
    
    public var centerPoint : RuntimePoint {
        return AnchorPoint(anchor: controlAnchor)
    }
}

extension ArcForm : Morphable {
    
    public enum AnchorId : AnchorIdentifier {
        case Start = 0
        case End = 1
        case Offset = 2
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.Start.rawValue:StaticPointAnchor(point: startPoint, name: "Start"),
            AnchorId.End.rawValue:StaticPointAnchor(point: endPoint, name: "End"),
            AnchorId.Offset.rawValue:controlAnchor,
        ]
    }
    
}

extension ArcForm : Drawable {
    
    public func getPathFor<R:Runtime>(runtime: R) -> Path? {
        guard let
            start = startPoint.getPositionFor(runtime),
            end = endPoint.getPositionFor(runtime),
            center = centerPoint.getPositionFor(runtime) else {
                return nil
        }

        let radius = (start-center).length
        let low = angle(start - center)
        let up = angle(end - center)
        var path = Path(center: center, radius: radius, lower: low, upper: up)

        path.append(.Close)

        return path
    }
    
    public func getShapeFor<R:Runtime>(runtime: R) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .PathArea(path), background: .Fill(Color(r: 128, g: 128, b: 128, a: 128)), stroke: .Solid(width: 1, color: Color(r:50, g:50, b:50, a: 255)))
    }
}
