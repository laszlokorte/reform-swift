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
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
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
    
    
    func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let c = center.getPositionFor(runtime),
            let angle = rotation.getAngleFor(runtime),
            let r = radius.getLengthFor(runtime) else {
                return nil
        }
        
        return c + rotate(Vec2d.XAxis * r, angle: angle)
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
    public func getPathFor(runtime: Runtime) -> Path? {
        guard let c = centerPoint.getPositionFor(runtime),
                  r = radius.getLengthFor(runtime),
                  low = angleLowerBound.getAngleFor(runtime).map(normalize360),
                  up = angleUpperBound.getAngleFor(runtime).map(normalize360) else {
            return nil
        }
        
        var path = Path(segments: .MoveTo(c))
        let arm = Vec2d(radius: r, angle: low)
        let end = Vec2d(radius: r, angle: up)
        let outer = Vec2d(radius: r*sqrt(2), angle: low + Angle(degree: -45))
        let count = abs(Int(normalize360(up-low).degree / 90))
        let rest = Angle(degree: normalize360(up-low).degree % 90)
        
        path.append(.LineTo(c+arm))
        for i in 0..<count {
            let a = c+rotate(outer, angle: Angle(degree: Double(90+90*i)))
            let b = c+rotate(arm, angle: Angle(degree: Double(90+90*i)))
            path.append(.ArcTo(
                tangent: a,
                tangent: b,
                radius: r)
            )
            
        }
        
        let restCos = (rest/2).cos
        if abs(rest.degree) > 1 {
            let a = c + Vec2d(
                radius: r/restCos,
                angle:  Angle(degree: Double(90*count))+rest/2+low)
            let b = c + end
            
            path.append(.ArcTo(
                tangent: a,
                tangent: b,
                radius: r)
            )
        
        }
        path.append(.Close)

        
        
        return path
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .PathArea(path), background: .Fill(Color(r: 128, g: 128, b: 128, a: 128)), stroke: .Solid(width: 1, color: Color(r:50, g:50, b:50, a: 255)))
    }
}