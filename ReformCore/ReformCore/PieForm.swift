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

final public class PieForm : Form, Creatable {
    public static var stackSize : Int = 5
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.Draw
    public var name : String
    
    
    public init(id formId: FormIdentifier, name : String) {
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
    
    public func initWithRuntime<R:Runtime>(runtime: R, min: Vec2d, max: Vec2d) {
        let c = (min+max) / 2
        let delta = max - min
        centerPoint.setPositionFor(runtime, position: c)
        radius.setLengthFor(runtime, length: delta.length/2)
        
        angleUpperBound.setAngleFor(runtime, angle: ReformMath.angle(delta) + Angle.PI)
        
        angleLowerBound.setAngleFor(runtime, angle: ReformMath.angle(delta))
    }
    
    public func getPoints() -> [ExposedPointIdentifier:protocol<RuntimePoint,Labeled>] {
        return [
            PointId.Start.rawValue:AnchorPoint(anchor: lowerAnchor),
            PointId.End.rawValue:AnchorPoint(anchor: upperAnchor),
            PointId.Center.rawValue:ExposedPoint(point: centerPoint, name: "Center"),
        ]
    }
    
    public var outline : Outline {
        let pointA = AnchorPoint(anchor: lowerAnchor)
        let pointB = AnchorPoint(anchor: upperAnchor)
        
        return CompositeOutline(parts:
            LineOutline(start: centerPoint, end: pointA),
            ArcOutline(center: centerPoint, radius: radius, angleA: angleLowerBound, angleB: angleUpperBound),
            LineOutline(start: pointB, end: centerPoint)
        )
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
    
    
    func getPositionFor<R:Runtime>(runtime: R) -> Vec2d? {
        guard let
            c = center.getPositionFor(runtime),
            angle = rotation.getAngleFor(runtime),
            r = radius.getLengthFor(runtime) else {
                return nil
        }
        
        return c + rotate(Vec2d.XAxis * r, angle: angle)
    }
    
    func translate<R:Runtime>(runtime: R, delta: Vec2d) {
        if let oldAngle = rotation.getAngleFor(runtime),
                oldRadius = radius.getLengthFor(runtime) {
            let oldDelta = rotate(Vec2d(x: oldRadius, y:0), angle: oldAngle)
                
            let newDelta = oldDelta + delta
                
            let newRadius = newDelta.length
            let newAngle = angle(newDelta)
                
            rotation.setAngleFor(runtime, angle: newAngle)
            radius.setLengthFor(runtime, length: newRadius)
        }
    }
}


extension PieCornerAnchor : Equatable {}

private func ==(lhs: PieCornerAnchor, rhs: PieCornerAnchor) -> Bool {
    return false // TODO
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
            AbsoluteScaler(scaler: BasicLengthScaler(length: radius, angle: angleUpperBound))
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
    public func getPathFor<R:Runtime>(runtime: R) -> Path? {
        guard let c = centerPoint.getPositionFor(runtime),
                  r = radius.getLengthFor(runtime),
                  low = angleLowerBound.getAngleFor(runtime),
                  up = angleUpperBound.getAngleFor(runtime)
        else {
            return nil
        }
        
        var path = Path(center: c, radius: r, lower: low, upper: up)

        path.append(.LineTo(c))

        path.append(.Close)


        return path
    }
    
    public func getShapeFor<R:Runtime>(runtime: R) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .PathArea(path), background: .Fill(Color(r: 128, g: 128, b: 128, a: 128)), stroke: .Solid(width: 1, color: Color(r:50, g:50, b:50, a: 255)))
    }
}