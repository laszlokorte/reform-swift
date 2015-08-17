//
//  PieForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath
import ReformGraphics


extension PieForm {
    
    public enum PointId : ExposedPointIdentifier {
        case Start = 0
        case End = 1
        case Center = 2
    }
}

final public class PieForm : Form {
    public static var stackSize : Int = 5
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.Draw
    public var name : String
    
    
    public init(formId: FormIdentifier, name : String) {
        self.identifier = formId
        self.name = name
    }
    
    public var centerPoint : WriteableRuntimePoint {
        return StaticPoint(formId: identifier, offset: 0)
    }
    
    public var radius : WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 2)
    }
    
    public var angleUpperBound : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 3)
    }
    
    public var angleLowerBound : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 4)
    }
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        let c = (min+max) / 2
        let delta = max - min
        centerPoint.setPositionFor(runtime, position: c)
        radius.setLengthFor(runtime, length: delta.length/2)
        
        angleUpperBound.setAngleFor(runtime, angle: ReformMath.angle(delta))
        
        angleLowerBound.setAngleFor(runtime, angle: ReformMath.angle(delta) - Angle.PI)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:protocol<RuntimePoint,Labeled>] {
        return [
            PointId.Start.rawValue:AnchorPoint(anchor: lowerAnchor),
            PointId.End.rawValue:AnchorPoint(anchor: upperAnchor),
            PointId.Center.rawValue:ExposedPoint(point: centerPoint, name: "Center"),
        ]
    }
    
    public var outline : Outline {
        return NullOutline()
    }
    
}

extension PieForm {
    
    var lowerAnchor : Anchor {
        return PieCornerAnchor(name: "Start", center: centerPoint, radius: radius, rotation: angleLowerBound)
    }
    
    var upperAnchor : Anchor {
        return PieCornerAnchor(name: "End", center: centerPoint, radius: radius, rotation: angleUpperBound)
    }
    
}


private struct PieCornerAnchor : Anchor {
    let center : WriteableRuntimePoint
    let rotation : WriteableRuntimeRotationAngle
    let radius : WriteableRuntimeLength
    let name : String
    
    init(name: String, center: WriteableRuntimePoint, radius: WriteableRuntimeLength, rotation: WriteableRuntimeRotationAngle) {
        self.center = center
        self.rotation = rotation
        self.radius = radius
        
        self.name = name
    }
    
    
    func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let c = center.getPositionFor(runtime),
            let angle = rotation.getAngleFor(runtime),
            let r = radius.getLengthFor(runtime) else {
                return nil
        }
        
        return c + rotate(Vec2d(x:r, y:r), angle: angle)
    }
    
    func translate(runtime: Runtime, delta: Vec2d) {
        if let oldAngle = rotation.getAngleFor(runtime),
            let oldRadius = radius.getLengthFor(runtime) {
            let oldDelta = rotate(Vec2d(x: oldRadius, y:0), angle: oldAngle)
                
            let newDelta = oldDelta + delta
                
            let newRadius = newDelta.length
            let newAngle = angle(newDelta)
                
            rotation.setAngleFor(runtime, angle: newAngle)
            radius.setLengthFor(runtime, length: newRadius)
        }
    }
}


extension PieForm : Rotatable {
    public var rotator : Rotator {
        return CompositeRotator(rotators:
            BasicPointRotator(points: centerPoint),
            BasicAngleRotator(angles: angleUpperBound),
            BasicAngleRotator(angles: angleLowerBound)
        )
    }
}

extension PieForm : Translatable {
    public var translator : Translator {
        return BasicPointTranslator(points: centerPoint)
    }
}

extension PieForm : Scalable {
    public var scaler : Scaler {
        return CompositeScaler(scalers:
            BasicPointScaler(points: centerPoint),
            BasicLengthScaler(length: radius, angle: angleUpperBound)
        )
    }
}

extension PieForm : Morphable {
    
    public enum AnchorId : AnchorIdentifier {
        case Start = 0
        case End = 1
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.Start.rawValue:lowerAnchor,
            AnchorId.End.rawValue:upperAnchor
        ]
    }
}

extension PieForm : Drawable {
    public func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
}