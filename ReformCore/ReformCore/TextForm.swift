//
//  TextForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public class TextForm : Form {
    public static var stackSize : Int = 5
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.Draw
    public var name : String
    
    
    init(formId: FormIdentifier, name : String) {
        self.identifier = formId
        self.name = name
    }
    
    var startPoint : WriteableRuntimePoint {
        return StaticPoint(formId: identifier, offset: 0)
    }
    
    var endPoint : WriteableRuntimePoint {
        return StaticPoint(formId: identifier, offset: 2)
    }
    
    var offset : WriteableRuntimeLength {
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
            ExposedPointIdentifier(1):ExposedPoint(point: startPoint, name: "End"),
            ExposedPointIdentifier(2):ExposedPoint(point: centerPoint, name: "Bottom"),
            ExposedPointIdentifier(3):AnchorPoint(anchor: controlPointAnchor)
        ]
    }
    
    public var outline : Outline {
        return NullOutline()
    }
}


extension TextForm {
    var controlPointAnchor : Anchor {
        return OrthogonalOffsetAnchor(name: "Control Point", pointA: startPoint, pointB: endPoint, offset: offset)
    }
    
    var startAnchor : Anchor {
        return StaticPointAnchor(point: startPoint, name: "Start")
    }
    
    var endAnchor : Anchor {
        return StaticPointAnchor(point: endPoint, name: "End")
    }
    
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
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorIdentifier(0):startAnchor,
            AnchorIdentifier(1):endAnchor,
            AnchorIdentifier(2):controlPointAnchor,
        ]
    }
}

extension TextForm : Drawable {
    
    public func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
}