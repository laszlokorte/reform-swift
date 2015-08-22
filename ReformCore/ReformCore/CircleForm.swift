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
        case Top = 0
        case Left = 1
        case Bottom = 2
        case Right = 3
        case Center = 4
    }
}

final public class CircleForm : Form, Creatable {
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
    
    public var angle : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 3)
    }
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
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
            PointId.Top.rawValue:AnchorPoint(anchor: topAnchor),
            PointId.Bottom.rawValue:AnchorPoint(anchor: bottomAnchor),
            PointId.Right.rawValue:AnchorPoint(anchor: rightAnchor),
            PointId.Left.rawValue:AnchorPoint(anchor: leftAnchor),
            PointId.Center.rawValue:ExposedPoint(point: centerPoint, name: "Center"),
        ]
    }
    
    public var outline : Outline {
        return CircleOutline(center: centerPoint, radius: radius, angle: angle)
    }
    
}

extension CircleForm {
    
    var topAnchor : Anchor {
        return CircleAnchor(quater: .North, center: centerPoint, radius: radius, rotation: angle)
    }
    
    var rightAnchor : Anchor {
        return CircleAnchor(quater: .East, center: centerPoint, radius: radius, rotation: angle)
    }
    
    var leftAnchor : Anchor {
        return CircleAnchor(quater: .West, center: centerPoint, radius: radius, rotation: angle)
    }
    
    var bottomAnchor : Anchor {
        return CircleAnchor(quater: .South, center: centerPoint, radius: radius, rotation: angle)
    }
    
}


private struct CircleAnchor : Anchor {
    enum Quater {
        case North
        case East
        case South
        case West
        
        var angle : Angle {
            switch self {
            case .North: return Angle(degree: 90)
            case .East: return Angle(radians: 0)
            case .South: return Angle(degree: -90)
            case .West: return  Angle(degree: 180)
            }
        }
        
        var name : String {
            switch self {
            case .North: return "North"
            case .East: return "East"
            case .South: return "South"
            case .West: return "West"
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
    
    
    func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let c = center.getPositionFor(runtime),
            let angle = rotation.getAngleFor(runtime),
            let r = radius.getLengthFor(runtime) else {
                return nil
        }
        
        return c + rotate(Vec2d.XAxis * r, angle: angle + quater.angle)
    }
    
    func translate(runtime: Runtime, delta: Vec2d) {
        if let oldAngle = rotation.getAngleFor(runtime),
            let oldRadius = radius.getLengthFor(runtime) {
            let oldDelta = rotate(Vec2d(x: oldRadius, y:0), angle: oldAngle)
                
            let newDelta = oldDelta + delta
                
            let newRadius = newDelta.length
            let newAngle = angle(newDelta) - quater.angle
                
            rotation.setAngleFor(runtime, angle: newAngle)
            radius.setLengthFor(runtime, length: newRadius)
        }
    }
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
        case Top = 0
        case Left = 1
        case Bottom = 2
        case Right = 3
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.Top.rawValue:topAnchor,
            AnchorId.Left.rawValue:leftAnchor,
            AnchorId.Right.rawValue:rightAnchor,
            AnchorId.Bottom.rawValue:bottomAnchor,
        ]
    }
}

extension CircleForm : Drawable {
    
    public func getPathFor(runtime: Runtime) -> Path? {
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
        
        return Path(segments: .MoveTo(left),
            .ArcTo(tangent: topLeft, tangent: top, radius: r),
            .ArcTo(tangent: topRight, tangent: right, radius: r),
            .ArcTo(tangent: bottomRight, tangent: bottom, radius: r),
            .ArcTo(tangent: bottomLeft, tangent: left, radius: r),
            .Close
        )
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .PathArea(path), background: .Fill(Color(r: 128, g: 128, b: 128, a: 128)), stroke: .Solid(width: 1, color: Color(r:50, g:50, b:50, a: 255)))

    }
}