//
//  Form.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

protocol Rotatable {
    var rotator : Rotator { get }
}

protocol Scalable {
    var scaler : Scaler { get }
}

protocol Translatable {
    var translator : Translator { get }
}

protocol Morphable {
    func getAnchors() -> [AnchorIdentifier:Anchor]
}

protocol Drawable {
    func getPathFor(runtime: Runtime) -> Path
    
    func getShapeFor(runtime: Runtime) -> Shape
    
    var drawingMode : DrawingMode { get set }
}

public typealias LabeledPoint = protocol<RuntimePoint, Labeled>

public protocol Form {
    static var stackSize : Int { get }
    
    var identifier : FormIdentifier { get }
    
    func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d)
    
    func getPoints() -> [ExposedPointIdentifier:LabeledPoint]
    
    var name : String { get set }
    
    var outline : Outline { get }
}