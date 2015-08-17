//
//  PictureForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath
import ReformGraphics

extension PictureForm : Rotatable {
    
    public var rotator : Rotator {
        return rectangle.rotator
    }
}

extension PictureForm : Translatable {
    
    public var translator : Translator {
        return rectangle.translator
    }
}

extension PictureForm : Scalable {
    public var scaler : Scaler {
        return rectangle.scaler
    }
}

extension PictureForm : Morphable {
    
    public func getAnchors() -> [AnchorIdentifier:Anchor] {
        return rectangle.getAnchors()
    }
}

extension PictureForm : Drawable {
    
    public var drawingMode : DrawingMode {
        get { return rectangle.drawingMode }
        set { rectangle.drawingMode = newValue }
    }
    
    public func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    public func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
}


final public class PictureForm : Form {
    public static var stackSize : Int = RectangleForm.stackSize
    
    private let rectangle : RectangleForm
    
    public var identifier : FormIdentifier {
        return rectangle.identifier
    }
    
    
    public var name : String {
        get { return rectangle.name }
        set { rectangle.name = newValue }
    }
    
    var pictureIdentifier : PictureIdentifier? = nil
    
    public init(id: FormIdentifier, name : String) {
        self.rectangle = RectangleForm(id: id, name: name)
    }
    
    var centerPoint : WriteableRuntimePoint {
        return rectangle.centerPoint
    }
    
    var width : WriteableRuntimeLength {
        return rectangle.width
    }
    
    var height : WriteableRuntimeLength {
        return rectangle.height
    }
    
    var angle : WriteableRuntimeRotationAngle {
        return rectangle.angle
    }
    
    public func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        rectangle.initWithRuntime(runtime, min: min, max: max)
    }
    
    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return rectangle.getPoints()
    }
    
    public var outline : Outline {
        return rectangle.outline
    }
    
}

extension PictureForm {
    public typealias AnchorId = RectangleForm.AnchorId
    public typealias PointId = RectangleForm.PointId
    
    public var topLeftAnchor : Anchor {
        return rectangle.topLeftAnchor
    }
    public var topRightAnchor : Anchor {
        return rectangle.topRightAnchor
    }
    public var bottomLeftAnchor : Anchor {
        return rectangle.bottomLeftAnchor
    }
    public var bottomRightAnchor : Anchor {
        return rectangle.bottomRightAnchor
    }
    public var topAnchor : Anchor {
        return rectangle.topAnchor
    }
    public var leftAnchor : Anchor {
        return rectangle.leftAnchor
    }
    public var rightAnchor : Anchor {
        return rectangle.rightAnchor
    }
    public var bottomAnchor : Anchor {
        return rectangle.bottomAnchor
    }
}
