//
//  ProxyForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics

extension ProxyForm {

    public enum PointId : ExposedPointIdentifier {
        case TopLeft = 0
        case BottomLeft = 1
        case TopRight = 2
        case BottomRight = 3
        case Top = 4
        case Bottom = 5
        case Left = 6
        case Right = 7
        case Center = 8
    }
}

extension ProxyForm {
    func initWithRuntime<R:Runtime>(runtime: R, formId: FormIdentifier) {

    }
}

final public class ProxyForm : Form {
    public static var stackSize : Int = 1

    public let identifier : FormIdentifier
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

    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.TopLeft.rawValue:AnchorPoint(anchor: topLeftAnchor),

            PointId.TopRight.rawValue:AnchorPoint(anchor: topRightAnchor),

            PointId.BottomLeft.rawValue:AnchorPoint(anchor: bottomLeftAnchor),

            PointId.BottomRight.rawValue:AnchorPoint(anchor: bottomRightAnchor),

            PointId.Top.rawValue:AnchorPoint(anchor: topAnchor),
            PointId.Bottom.rawValue:AnchorPoint(anchor: bottomAnchor),
            PointId.Right.rawValue:AnchorPoint(anchor: rightAnchor),
            PointId.Left.rawValue:AnchorPoint(anchor: leftAnchor),
            PointId.Center.rawValue:ExposedPoint(point: centerPoint, name: "Center"),
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

extension ProxyForm {

    public var topLeftAnchor : Anchor {
        return ProxyAnchor(side: .TopLeft, center: centerPoint, rotation: angle, width: width, height: height)
    }

    public var topRightAnchor : Anchor {
        return ProxyAnchor(side: .TopRight, center: centerPoint, rotation: angle, width: width, height: height)
    }

    public var bottomLeftAnchor : Anchor {
        return ProxyAnchor(side: .BottomLeft, center: centerPoint, rotation: angle, width: width, height: height)
    }

    public var bottomRightAnchor : Anchor {
        return ProxyAnchor(side: .BottomRight, center: centerPoint, rotation: angle, width: width, height: height)
    }

    public var topAnchor : Anchor {
        return ProxyAnchor(side: .Top, center: centerPoint, rotation: angle, width: width, height: height)
    }

    public var rightAnchor : Anchor {
        return ProxyAnchor(side: .Right, center: centerPoint, rotation: angle, width: width, height: height)
    }

    public var leftAnchor : Anchor {
        return ProxyAnchor(side: .Left, center: centerPoint, rotation: angle, width: width, height: height)
    }

    public var bottomAnchor : Anchor {
        return ProxyAnchor(side: .Bottom, center: centerPoint, rotation: angle, width: width, height: height)
    }

}


private struct ProxyAnchor : Anchor {
    enum Side {
        case Left
        case Right
        case Top
        case Bottom
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight

        var x : Int {
            switch self {
            case Left, TopLeft, BottomLeft:
                return -1
            case Right, TopRight, BottomRight:
                return 1
            case Top, Bottom:
                return 0
            }
        }

        var y : Int {
            switch self {
            case Top, TopLeft, TopRight:
                return -1
            case Bottom, BottomLeft, BottomRight:
                return 1
            case Left, Right:
                return 0
            }
        }

        var name : String {
            switch self {
            case .Top: return "Top"
            case .Right: return "Right"
            case .Left: return "Left"
            case .Bottom: return "Bottom"
            case .TopLeft: return "Top Left"
            case .TopRight: return "Top Right"
            case .BottomLeft: return "Bottom Left"
            case .BottomRight: return "Bottom Right"
            }
        }

        var corner : Bool {
            switch self {
            case .Top, .Right, .Bottom, .Left: return false
            case .TopLeft, .TopRight, .BottomLeft, .BottomRight: return true
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


    func getPositionFor<R:Runtime>(runtime: R) -> Vec2d? {
        guard let
            c = center.getPositionFor(runtime),
            angle = rotation.getAngleFor(runtime),
            w = width.getLengthFor(runtime),
            h = height.getLengthFor(runtime) else {
                return nil
        }

        return c + rotate(Vec2d(x:Double(side.x)*w, y:Double(side.y)*h)/2, angle: angle)
    }

    func translate<R:Runtime>(runtime: R, delta: Vec2d) {
        if let
            oldAngle = rotation.getAngleFor(runtime),
            oldWidth = width.getLengthFor(runtime),
            oldHeight = height.getLengthFor(runtime),
            oldCenter = center.getPositionFor(runtime) {

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

extension ProxyAnchor : Equatable {}

private func ==(lhs: ProxyAnchor, rhs: ProxyAnchor) -> Bool {
    return lhs.name == rhs.name && lhs.side == rhs.side && lhs.center.isEqualTo(rhs.center) && lhs.rotation.isEqualTo(rhs.rotation) && lhs.width.isEqualTo(rhs.width) && lhs.height.isEqualTo(rhs.height)
}

extension ProxyForm : Rotatable {

    public var rotator : Rotator {
        return CompositeRotator(rotators:
            BasicPointRotator(points: centerPoint),
            BasicAngleRotator(angles: angle)
        )
    }
}

extension ProxyForm : Translatable {

    public var translator : Translator {
        return BasicPointTranslator(points: centerPoint)
    }
}

extension ProxyForm : Scalable {

    public var scaler : Scaler {
        return CompositeScaler(scalers:
            BasicPointScaler(points: centerPoint),
            BasicLengthScaler(length: width, angle: angle),
            BasicLengthScaler(length: height, angle: angle, offset: Angle(degree: 90))
        )
    }
}

extension ProxyForm : Morphable {

    public enum AnchorId : AnchorIdentifier {
        case TopLeft = 0
        case BottomLeft = 1
        case TopRight = 2
        case BottomRight = 3
        case Top = 4
        case Bottom = 5
        case Left = 6
        case Right = 7
    }

    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorId.TopLeft.rawValue:topLeftAnchor,
            AnchorId.TopRight.rawValue:topRightAnchor,
            AnchorId.BottomLeft.rawValue:bottomLeftAnchor,
            AnchorId.BottomRight.rawValue:bottomRightAnchor,

            AnchorId.Top.rawValue:topAnchor,
            AnchorId.Bottom.rawValue:bottomAnchor,
            AnchorId.Left.rawValue:leftAnchor,
            AnchorId.Right.rawValue:rightAnchor,
        ]
    }
}