//
//  TextForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

class TextForm : Form, Rotatable, Translatable, Scalable, Morphable, Drawable {
    static var stackSize : Int = 5
    
    let identifier : FormIdentifier
    var drawingMode : DrawingMode = DrawingMode.Draw
    var name : String
    
    
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
    
    func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
        offset.setLengthFor(runtime, length: 16)
    }
    
    func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
    
    func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            ExposedPointIdentifier(0):ExposedPoint(point: startPoint, name: "Start"),
            ExposedPointIdentifier(1):ExposedPoint(point: startPoint, name: "End"),
            ExposedPointIdentifier(2):ExposedPoint(point: centerPoint, name: "Bottom"),
            ExposedPointIdentifier(3):AnchorPoint(anchor: controlPointAnchor)
        ]
    }
    
    var rotator : Rotator {
        return BasicPointRotator(points: startPoint, endPoint)
    }
    var scaler : Scaler {
        return BasicPointScaler(points: startPoint, endPoint)
    }
    
    var translator : Translator {
        return BasicPointTranslator(points: startPoint, endPoint)
    }
    
    
    func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorIdentifier(0):startAnchor,
            AnchorIdentifier(1):endAnchor,
            AnchorIdentifier(2):controlPointAnchor,
        ]
    }
    
    var outline : Outline {
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