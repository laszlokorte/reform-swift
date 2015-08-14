//
//  LineForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

class LineForm : Form, Rotatable, Translatable, Scalable, Morphable, Drawable {
    static var stackSize : Int = 4
    
    let identifier : FormIdentifier
    var drawingMode : DrawingMode = DrawingMode.Draw
    var name : String

    
    init(formId: FormIdentifier, name : String) {
        self.identifier = formId
        self.name = name
    }
    
    var startPoint : WriteableRuntimePoint {
        get { return StaticPoint(formId: identifier, offset: 0) }
    }
    
    var endPoint : WriteableRuntimePoint {
        get { return StaticPoint(formId: identifier, offset: 2) }
    }
    
    func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
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
            ExposedPointIdentifier(2):ExposedPoint(point: CenterPoint(pointA: startPoint, pointB: endPoint), name: "Center"),
        ]
    }
    
    var rotator : Rotator {
        get {
            return BasicPointRotator(points: startPoint, endPoint)
        }
    }
    var scaler : Scaler {
        get {
            return BasicPointScaler(points: startPoint, endPoint)
        }
    }
    
    var translator : Translator {
        get {
            return BasicPointTranslator(points: startPoint, endPoint)
        }
    }

    
    func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorIdentifier(0):StaticPointAnchor(point: startPoint, name: "Start"),
            AnchorIdentifier(1):StaticPointAnchor(point: endPoint, name: "End"),
        ]
    }
    
    var outline : Outline {
        get {
            return LineOutline(start: startPoint, end: endPoint)
        }
    }
}