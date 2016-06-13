//
//  Form.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics

public protocol Rotatable {
    var rotator : Rotator { get }
}

public protocol Scalable {
    var scaler : Scaler { get }
}

public protocol Translatable {
    var translator : Translator { get }
}

public protocol Morphable {
    func getAnchors() -> [AnchorIdentifier:Anchor]
}

public protocol Drawable {
    func getPathFor<R:Runtime>(_ runtime: R) -> Path?
    
    func getShapeFor<R:Runtime>(_ runtime: R) -> Shape?
    
    var drawingMode : DrawingMode { get set }
}

public typealias LabeledPoint = protocol<RuntimePoint, Labeled>

public protocol Creatable {
    init(id: FormIdentifier, name: String)


    func initWithRuntime<R:Runtime>(_ runtime: R, min: Vec2d, max: Vec2d)
}

public protocol Form {
    static var stackSize : Int { get }
    
    var identifier : FormIdentifier { get }

    func getPoints() -> [ExposedPointIdentifier:LabeledPoint]
    
    var name : String { get set }
    
    var outline : Outline { get }
}
