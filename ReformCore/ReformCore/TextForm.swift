//
//  TextForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics

extension TextForm {
    
    public enum PointId : ExposedPointIdentifier {
        case start = 0
        case end = 1
        case bottom = 2
        case top = 3
    }
}

final public class TextForm : Form, Creatable {
    public static var stackSize : Int = 5
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.draw
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
    
    public func initWithRuntime<R:Runtime>(_ runtime: R, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
        offset.setLengthFor(runtime, length: 16)
    }
    
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.start.rawValue:ExposedPoint(point: startPoint, name: "Start"),
            PointId.end.rawValue:ExposedPoint(point: endPoint, name: "End"),
            PointId.bottom.rawValue:ExposedPoint(point: centerPoint, name: "Bottom"),
            PointId.top.rawValue:AnchorPoint(anchor: controlPointAnchor)
        ]
    }
    
    public var outline : Outline {
        return LineOutline(start: startPoint, end: endPoint)
    }
}


extension TextForm {
    
    var centerPoint : LabeledPoint {
        return ExposedPoint(point: CenterPoint(pointA: startPoint, pointB: endPoint), name: "Center")
    }
}


extension TextForm : Rotatable {
    
    public var rotator : Rotator {
        return BasicPointRotator(points: startPoint, endPoint)
    }
}

extension TextForm : Translatable {
    
    public var translator : Translator {
        return BasicPointTranslator(points: startPoint, endPoint)
    }
}

extension TextForm : Scalable {
    
    public var scaler : Scaler {
        return CompositeScaler(scalers: BasicPointScaler(points: startPoint, endPoint),
            AbsoluteScaler(scaler: BasicLengthScaler(length: offset, angle: ConstantAngle()))
        )
    }
}

extension TextForm : Morphable {
    
    public enum AnchorId : AnchorIdentifier {
        case start = 0
        case end = 1
        case top = 2
    }

    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.start.rawValue:startAnchor,
            AnchorId.end.rawValue:endAnchor,
            AnchorId.top.rawValue:controlPointAnchor,
        ]
    }
    
    var controlPointAnchor : Anchor {
        return OrthogonalOffsetAnchor(name: "Control Point", pointA: endPoint, pointB: startPoint, offset: offset)
    }
    
    var startAnchor : Anchor {
        return StaticPointAnchor(point: startPoint, name: "Start")
    }
    
    var endAnchor : Anchor {
        return StaticPointAnchor(point: endPoint, name: "End")
    }
}

extension TextForm : Drawable {
    
    public func getPathFor<R:Runtime>(_ runtime: R) -> Path? {
        guard let center = centerPoint.getPositionFor(runtime),
            end = endPoint.getPositionFor(runtime),
            start = startPoint.getPositionFor(runtime),
            ctrl = controlPointAnchor.getPositionFor(runtime) else {
                return nil
        }

        let up = ctrl - center

        return Path(segments: .moveTo(start), .lineTo(end), .lineTo(end+up), .lineTo(start+up), .close)
    }
    
    public func getShapeFor<R:Runtime>(_ runtime: R) -> Shape? {
        guard let start = startPoint.getPositionFor(runtime),
                end = endPoint.getPositionFor(runtime),
                size = offset.getLengthFor(runtime) else {
            return nil
        }

        return Shape(area: .textArea(start, end, alignment: .center, text: "Test", size: size), background: .fill(ReformGraphics.Color(r: 40, g: 40, b: 40, a: 125)), stroke: .none)
    }
}
