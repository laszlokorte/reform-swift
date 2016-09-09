//
//  RectangleForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics

extension RectangleForm {
    
    public enum PointId : ExposedPointIdentifier {
        case topLeft = 0
        case bottomLeft = 1
        case topRight = 2
        case bottomRight = 3
        case top = 4
        case bottom = 5
        case left = 6
        case right = 7
        case center = 8
    }
}

final public class RectangleForm : Form, Creatable {
    public static var stackSize : Int = 5
    
    public let identifier : FormIdentifier
    public var drawingMode : DrawingMode = DrawingMode.draw
    public var name : String
    
    
    public init(id: FormIdentifier, name : String) {
        self.identifier = id
        self.name = name
    }
    
    var centerPoint : WriteableRuntimePoint {
        return StaticPoint(formId: identifier, offset: 0)
    }
    
    var width : WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 2)
    }
    
    var height : WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 3)
    }
    
    var angle : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 4)
    }
    
    public func initWithRuntime<R:Runtime>(_ runtime: R, min: Vec2d, max: Vec2d) {
        let w = max.x - min.x
        let h = max.y - min.y
        let c = (min+max) / 2
                
        centerPoint.setPositionFor(runtime, position: c)
        width.setLengthFor(runtime, length: abs(w))
        height.setLengthFor(runtime, length: abs(h))
        angle.setAngleFor(runtime, angle: Angle(radians: 0))
    }
    
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.topLeft.rawValue:AnchorPoint(anchor: topLeftAnchor),
            
            PointId.topRight.rawValue:AnchorPoint(anchor: topRightAnchor),
            
            PointId.bottomLeft.rawValue:AnchorPoint(anchor: bottomLeftAnchor),
            
            PointId.bottomRight.rawValue:AnchorPoint(anchor: bottomRightAnchor),
            
            PointId.top.rawValue:AnchorPoint(anchor: topAnchor),
            PointId.bottom.rawValue:AnchorPoint(anchor: bottomAnchor),
            PointId.right.rawValue:AnchorPoint(anchor: rightAnchor),
            PointId.left.rawValue:AnchorPoint(anchor: leftAnchor),
            PointId.center.rawValue:ExposedPoint(point: centerPoint, name: "Center"),
        ]
    }
    
    public var outline : Outline {
        return CompositeOutline(parts:
            LineOutline(start: AnchorPoint(anchor: topLeftAnchor), end: AnchorPoint(anchor: topRightAnchor)),
            
            LineOutline(start: AnchorPoint(anchor: topRightAnchor), end: AnchorPoint(anchor: bottomRightAnchor)),
            
            LineOutline(start: AnchorPoint(anchor: bottomRightAnchor), end: AnchorPoint(anchor: bottomLeftAnchor)),
    
            LineOutline(start: AnchorPoint(anchor: bottomLeftAnchor), end: AnchorPoint(anchor: topLeftAnchor))
        )
    }
    
}

extension RectangleForm {

    public var topLeftAnchor : Anchor {
        return RectangleAnchor(side: .topLeft, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
    public var topRightAnchor : Anchor {
        return RectangleAnchor(side: .topRight, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
    public var bottomLeftAnchor : Anchor {
        return RectangleAnchor(side: .bottomLeft, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
    public var bottomRightAnchor : Anchor {
        return RectangleAnchor(side: .bottomRight, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
    public var topAnchor : Anchor {
        return RectangleAnchor(side: .top, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
    public var rightAnchor : Anchor {
        return RectangleAnchor(side: .right, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
    public var leftAnchor : Anchor {
        return RectangleAnchor(side: .left, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
    public var bottomAnchor : Anchor {
        return RectangleAnchor(side: .bottom, center: centerPoint, rotation: angle, width: width, height: height)
    }
    
}


private struct RectangleAnchor : Anchor {
    enum Side {
        case left
        case right
        case top
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        
        var x : Int {
            switch self {
            case .left, .topLeft, .bottomLeft:
                return -1
            case .right, .topRight, .bottomRight:
                return 1
            case .top, .bottom:
                return 0
            }
        }
        
        var y : Int {
            switch self {
            case .top, .topLeft, .topRight:
                return -1
            case .bottom, .bottomLeft, .bottomRight:
                return 1
            case .left, .right:
                return 0
            }
        }
        
        var name : String {
            switch self {
            case .top: return "Top"
            case .right: return "Right"
            case .left: return "Left"
            case .bottom: return "Bottom"
            case .topLeft: return "Top Left"
            case .topRight: return "Top Right"
            case .bottomLeft: return "Bottom Left"
            case .bottomRight: return "Bottom Right"
            }
        }
        
        var corner : Bool {
            switch self {
                case .top, .right, .bottom, .left: return false
                case .topLeft, .topRight, .bottomLeft, .bottomRight: return true
            }
        }
    }
    
    let side : Side
    let center : WriteableRuntimePoint
    let rotation : WriteableRuntimeRotationAngle
    let width : WriteableRuntimeLength
    let height : WriteableRuntimeLength
    let name : String
    
    init(side: Side, center: WriteableRuntimePoint, rotation: WriteableRuntimeRotationAngle, width: WriteableRuntimeLength, height: WriteableRuntimeLength) {
        self.side = side
        self.center = center
        self.rotation = rotation
        self.width = width
        self.height = height
        
        name = side.name
    }
    
    
    func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            c = center.getPositionFor(runtime),
            let angle = rotation.getAngleFor(runtime),
            let w = width.getLengthFor(runtime),
            let h = height.getLengthFor(runtime) else {
                return nil
        }
        
        return c + rotate(Vec2d(x:Double(side.x)*w, y:Double(side.y)*h)/2, angle: angle)
    }
    
    func translate<R:Runtime>(_ runtime: R, delta: Vec2d) {
        if let
            oldAngle = rotation.getAngleFor(runtime),
            let oldWidth = width.getLengthFor(runtime),
            let oldHeight = height.getLengthFor(runtime),
            let oldCenter = center.getPositionFor(runtime) {
                
                let oldSize = Vec2d(x: oldWidth, y: oldHeight)
                let oldDelta = rotate(Vec2d(x: Double(side.x)*oldSize.x, y: Double(side.y)*oldSize.y) / 2, angle: oldAngle)
                
                let old = oldCenter + oldDelta
                let opposite = oldCenter - oldDelta
                
                let new = old + project(delta, onto: oldDelta * (side.corner ? 0 : 1))
                
                
                let newCenter = (opposite + new) / 2
                let newHalfSize = rotate(new - newCenter, angle: -oldAngle)

                let newWidth = oldWidth + Double(side.x) * (2*newHalfSize.x - Double(side.x) * (oldSize.x))
                let newHeight = oldHeight + Double(side.y) * (2*newHalfSize.y - Double(side.y) * (oldSize.y))
                
                
                center.setPositionFor(runtime, position: newCenter)
                height.setLengthFor(runtime, length: newHeight)
                width.setLengthFor(runtime, length: newWidth)
        }
    }
}

extension RectangleAnchor : Equatable {}

private func ==(lhs: RectangleAnchor, rhs: RectangleAnchor) -> Bool {
    return lhs.name == rhs.name && lhs.side == rhs.side && lhs.center.isEqualTo(rhs.center) && lhs.rotation.isEqualTo(rhs.rotation) && lhs.width.isEqualTo(rhs.width) && lhs.height.isEqualTo(rhs.height)
}

extension RectangleForm : Rotatable {
    
    public var rotator : Rotator {
        return CompositeRotator(rotators:
            BasicPointRotator(points: centerPoint),
            BasicAngleRotator(angles: angle)
        )
    }
}

extension RectangleForm : Translatable {
    
    public var translator : Translator {
        return BasicPointTranslator(points: centerPoint)
    }
}

extension RectangleForm : Scalable {
    
    public var scaler : Scaler {
        return CompositeScaler(scalers:
            BasicPointScaler(points: centerPoint),
            BasicLengthScaler(length: width, angle: angle),
            BasicLengthScaler(length: height, angle: angle, offset: Angle(degree: 90))
        )
    }
}

extension RectangleForm : Morphable {

    public enum AnchorId : AnchorIdentifier {
        case topLeft = 0
        case bottomLeft = 1
        case topRight = 2
        case bottomRight = 3
        case top = 4
        case bottom = 5
        case left = 6
        case right = 7
    }
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.topLeft.rawValue:topLeftAnchor,
            AnchorId.topRight.rawValue:topRightAnchor,
            AnchorId.bottomLeft.rawValue:bottomLeftAnchor,
            AnchorId.bottomRight.rawValue:bottomRightAnchor,
            
            AnchorId.top.rawValue:topAnchor,
            AnchorId.bottom.rawValue:bottomAnchor,
            AnchorId.left.rawValue:leftAnchor,
            AnchorId.right.rawValue:rightAnchor,
        ]
    }
}

extension RectangleForm : Drawable {
    
    public func getPathFor<R:Runtime>(_ runtime: R) -> Path? {
        guard
            let topLeft = topLeftAnchor.getPositionFor(runtime),
            let topRight = topRightAnchor.getPositionFor(runtime),
            let bottomRight = bottomRightAnchor.getPositionFor(runtime),
            let bottomLeft = bottomLeftAnchor.getPositionFor(runtime)
        else {
                return nil
        }
        
        return Path(segments: .moveTo(topLeft), .lineTo(topRight), .lineTo(bottomRight), .lineTo(bottomLeft), .close)
    }
    
    public func getShapeFor<R:Runtime>(_ runtime: R) -> Shape? {
        guard let path = getPathFor(runtime) else { return nil }
        
        return Shape(area: .pathArea(path), background: .fill(ReformGraphics.Color(r: 128, g: 128, b: 128, a: 128)), stroke: .solid(width: 1, color: ReformGraphics.Color(r:50, g:50, b:50, a: 255)))
    }
}
