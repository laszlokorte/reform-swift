//
//  ArcForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public class ArcForm : Form {
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
        offset.setLengthFor(runtime, length: 50)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            ExposedPointIdentifier(0):ExposedPoint(point: startPoint, name: "Start"),
            ExposedPointIdentifier(1):ExposedPoint(point: startPoint, name: "End"),
            ExposedPointIdentifier(2):ExposedPoint(point: CenterPoint(pointA: startPoint, pointB: endPoint), name: "Center"),
        ]
    }
    
    public var outline : Outline {
        return NullOutline()
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
        return BasicPointScaler(points: startPoint, endPoint)
    }
    
}

extension ArcForm : Morphable {
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorIdentifier(0):StaticPointAnchor(point: startPoint, name: "Start"),
            AnchorIdentifier(1):StaticPointAnchor(point: endPoint, name: "End"),
            AnchorIdentifier(2):OrthogonalOffsetAnchor(name: "Control Point", pointA: startPoint, pointB: endPoint, offset: offset),
        ]
    }
    
}

extension ArcForm : Drawable {
    
    public func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
}
