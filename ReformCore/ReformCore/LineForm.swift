//
//  LineForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public class LineForm : Form{
    public static var stackSize : Int = 4
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.Draw
    public var name : String

    
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
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        startPoint.setPositionFor(runtime, position: min)
        endPoint.setPositionFor(runtime, position: max)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            ExposedPointIdentifier(0):ExposedPoint(point: startPoint, name: "Start"),
            ExposedPointIdentifier(1):ExposedPoint(point: startPoint, name: "End"),
            ExposedPointIdentifier(2):ExposedPoint(point: CenterPoint(pointA: startPoint, pointB: endPoint), name: "Center"),
        ]
    }
    
    public var outline : Outline {
        get {
            return LineOutline(start: startPoint, end: endPoint)
        }
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
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorIdentifier(0):StaticPointAnchor(point: startPoint, name: "Start"),
            AnchorIdentifier(1):StaticPointAnchor(point: endPoint, name: "End"),
        ]
    }
}

extension LineForm : Drawable {
    public func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
}
