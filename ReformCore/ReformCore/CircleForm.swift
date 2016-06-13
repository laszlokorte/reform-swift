//
//  Circle.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath
import ReformGraphics

extension CircleForm {
    
    public enum PointId : ExposedPointIdentifier {
        case top = 0
        case left = 1
        case bottom = 2
        case right = 3
        case center = 4
    }
}

final public class CircleForm : Form, Creatable {
    public static var stackSize : Int = 5
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.draw
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
    
    public var angle : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 3)
    }
    
    public func initWithRuntime<R:Runtime>(_ runtime: R, min: Vec2d, max: Vec2d) {
        let c = (min+max) / 2
        let delta = max - min
        
        let r = delta.length / 2
        let a = ReformMath.angle(delta)
                
        centerPoint.setPositionFor(runtime, position: c)
        radius.setLengthFor(runtime, length: r)
        angle.setAngleFor(runtime, angle: a)
        
    }
    
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.top.rawValue:AnchorPoint(anchor: topAnchor),
            PointId.bottom.rawValue:AnchorPoint(anchor: bottomAnchor),
            PointId.right.rawValue:AnchorPoint(anchor: rightAnchor),
            PointId.left.rawValue:AnchorPoint(anchor: leftAnchor),
            PointId.center.rawValue:ExposedPoint(point: centerPoint, name: "Center"),
        ]
    }
    
    public var outline : Outline {
        return CircleOutline(center: centerPoint, radius: radius, angle: angle)
    }
    
}

extension CircleForm {
    
    var topAnchor : Anchor {
        return CircleAnchor(quater: .north, center: centerPoint, radius: radius, rotation: angle)
    }
    
    var rightAnchor : Anchor {
        return CircleAnchor(quater: .east, center: centerPoint, radius: radius, rotation: angle)
    }
    
    var leftAnchor : Anchor {
        return CircleAnchor(quater: .west, center: centerPoint, radius: radius, rotation: angle)
    }
    
    var bottomAnchor : Anchor {
        return CircleAnchor(quater: .south, center: centerPoint, radius: radius, rotation: angle)
    }
    
}


private struct CircleAnchor : Anchor {
    enum Quater {
        case north
        case east
        case south
        case west
        
        var angle : Angle {
            switch self {
            case .north: return Angle(degree: 90)
            case .east: return Angle(radians: 0)
            case .south: return Angle(degree: -90)
            case .west: return  Angle(degree: 180)
            }
        }
        
        var name : String {
            switch self {
            case .north: return "North"
            case .east: return "East"
            case .south: return "South"
            case .west: return "West"
            }
        }
    }
    
    let quater : Quater
    let center : WriteableRuntimePoint
    let rotation : WriteableRuntimeRotationAngle
    let radius : WriteableRuntimeLength
    let name : String
    
    init(quater: Quater, center: WriteableRuntimePoint, radius: WriteableRuntimeLength, rotation: WriteableRuntimeRotationAngle) {
        self.quater = quater
        self.center = center
        self.rotation = rotation
        self.radius = radius
        
        name = quater.name
    }
    
    
    func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            c = center.getPositionFor(runtime),
            angle = rotation.getAngleFor(runtime),
            r = radius.getLengthFor(runtime) else {
                return nil
        }
        
        return c + rotate(Vec2d.XAxis * r, angle: angle + quater.angle)
    }
    
    func translate<R:Runtime>(_ runtime: R, delta: Vec2d) {
        guard let
            oldAngle = rotation.getAngleFor(runtime),
            oldRadius = radius.getLengthFor(runtime) else {
                return
        }
        
        let oldDelta = rotate(Vec2d.XAxis * oldRadius, angle: oldAngle + quater.angle)
        
        let newDelta = oldDelta + delta
            
        let newRadius = newDelta.length
        let newAngle = angle(newDelta) - quater.angle
            
        rotation.setAngleFor(runtime, angle: newAngle)
        radius.setLengthFor(runtime, length: newRadius)
    }
}

extension CircleAnchor : Equatable {}

private func ==(lhs: CircleAnchor, rhs: CircleAnchor) -> Bool {
    return lhs.name == rhs.name && lhs.quater == rhs.quater && lhs.center.isEqualTo(rhs.center) && lhs.rotation.isEqualTo(rhs.rotation) && lhs.radius.isEqualTo(rhs.radius)
}


extension CircleForm : Rotatable {
    
    public var rotator : Rotator {
        return CompositeRotator(rotators:
            BasicPointRotator(points: centerPoint),
            BasicAngleRotator(angles: angle)
        )
    }
}

extension CircleForm : Translatable {
    public var translator : Translator {
        return BasicPointTranslator(points: centerPoint)
    }
}

extension CircleForm : Scalable {
    public var scaler : Scaler {
        return CompositeScaler(scalers:
            BasicPointScaler(points: centerPoint),
            BasicLengthScaler(length: radius, angle: angle)
        )
    }
}

extension CircleForm : Morphable {
    public enum AnchorId : AnchorIdentifier {
        case top = 0
        case left = 1
        case bottom = 2
        case right = 3
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.top.rawValue:topAnchor,
            AnchorId.left.rawValue:leftAnchor,
            AnchorId.right.rawValue:rightAnchor,
            AnchorId.bottom.rawValue:bottomAnchor,
        ]
    }
}

extension CircleForm : Drawable {
    
    public func getPathFor<R:Runtime>(_ runtime: R) -> Path? {
        guard
            let c = centerPoint.getPositionFor(runtime),
            let rd = radius.getLengthFor(runtime)
            else {
                return nil
        }
        
        let r = abs(rd)
        let left = c - Vec2d(x:r, y: 0)
        let right = c + Vec2d(x:r, y: 0)
        let top = c - Vec2d(x:0, y: r)
        let bottom = c + Vec2d(x:0, y: r)
        
        let topLeft = c + Vec2d(x:-r, y: -r)
        let topRight = c + Vec2d(x:r, y: -r)
        let bottomLeft = c + Vec2d(x:-r, y: r)
        let bottomRight = c + Vec2d(x:r, y: r)
        
        return Path(segments: .moveTo(left),
            .arcTo(tangent: topLeft, tangent: top, radius: r),
            .arcTo(tangent: topRight, tangent: right, radius: r),
            .arcTo(tangent: bottomRight, tangent: bottom, radius: r),
            .arcTo(tangent: bottomLeft, tangent: left, radius: r),
            .close
        )
    }
    
    public func getShapeFor<R:Runtime>(_ runtime: R) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .pathArea(path), background: .fill(ReformGraphics.Color(r: 128, g: 128, b: 128, a: 128)), stroke: .solid(width: 1, color: ReformGraphics.Color(r:50, g:50, b:50, a: 255)))

    }
}
