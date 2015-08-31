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
        case Start = 0
        case End = 1
        case Center = 2
    }
}

final public class TextForm : Form, Creatable {
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
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
        offset.setLengthFor(runtime, length: 16)
    }
    
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            ExposedPointIdentifier(0):ExposedPoint(point: startPoint, name: "Start"),
            ExposedPointIdentifier(1):ExposedPoint(point: endPoint, name: "End"),
            ExposedPointIdentifier(2):ExposedPoint(point: centerPoint, name: "Bottom"),
            ExposedPointIdentifier(3):AnchorPoint(anchor: controlPointAnchor)
        ]
    }
    
    public var outline : Outline {
        return NullOutline()
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
        return BasicPointScaler(points: startPoint, endPoint)
    }
}

extension TextForm : Morphable {
    
    public enum AnchorId : AnchorIdentifier {
        case Start = 0
        case End = 1
        case Offset = 2
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.Start.rawValue:startAnchor,
            AnchorId.End.rawValue:endAnchor,
            AnchorId.Offset.rawValue:controlPointAnchor,
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
    
    public func getPathFor(runtime: Runtime) -> Path? {
        guard let center = centerPoint.getPositionFor(runtime),
            end = endPoint.getPositionFor(runtime),
            start = startPoint.getPositionFor(runtime),
            ctrl = controlPointAnchor.getPositionFor(runtime) else {
                return nil
        }

        let up = ctrl - center

        return Path(segments: .MoveTo(start), .LineTo(end), .LineTo(end+up), .LineTo(start+up), .Close)
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape? {
        guard let start = startPoint.getPositionFor(runtime),
                end = endPoint.getPositionFor(runtime),
                size = offset.getLengthFor(runtime) else {
            return nil
        }

        return Shape(area: .TextArea(start, end, alignment: .Center, text: "Test", size: size), background: .Fill(Color(r: 40, g: 40, b: 40, a: 255)), stroke: .None)
    }
}