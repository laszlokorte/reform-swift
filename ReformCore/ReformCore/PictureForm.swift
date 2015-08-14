//
//  PictureForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

class PictureForm : Form, Rotatable, Translatable, Scalable, Morphable, Drawable {
    static var stackSize : Int = RectangleForm.stackSize
    
    private let rectangle : RectangleForm
    
    var identifier : FormIdentifier {
        return rectangle.identifier
    }
    
    var drawingMode : DrawingMode {
        get { return rectangle.drawingMode }
        set { rectangle.drawingMode = newValue }
    }
    
    var name : String {
        get { return rectangle.name }
        set { rectangle.name = newValue }
    }
    
    var pictureIdentifier : PictureIdentifier? = nil
    
    init(formId: FormIdentifier, name : String) {
        self.rectangle = RectangleForm(formId: formId, name: name)
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
    
    func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        rectangle.initWithRuntime(runtime, min: min, max: max)
    }
    
    func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
    
    func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return rectangle.getPoints()
    }
    
    var rotator : Rotator {
        return rectangle.rotator
    }
    var scaler : Scaler {
        return rectangle.scaler
    }
    
    var translator : Translator {
        return rectangle.translator
    }
    
    
    func getAnchors() -> [AnchorIdentifier:Anchor] {
        return rectangle.getAnchors()
    }
    
    var outline : Outline {
        return rectangle.outline
    }
    
}
