//
//  PieForm.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

class PieForm : Form, Rotatable, Translatable, Scalable, Morphable, Drawable {
    static var stackSize : Int = 5
    
    let identifier : FormIdentifier
    var drawingMode : DrawingMode = DrawingMode.Draw
    var name : String
    
    
    init(formId: FormIdentifier, name : String) {
        self.identifier = formId
        self.name = name
    }
    
    var centerPoint : WriteableRuntimePoint {
        return StaticPoint(formId: identifier, offset: 0)
    }
    
    var radius : WriteableRuntimeLength {
        return StaticLength(formId: identifier, offset: 2)
    }
    
    var angleUpperBound : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 3)
    }
    var angleLowerBound : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 4)
    }
    
    func initWithRuntime(runtime: Runtime, min: Vec2d, max: Vec2d) {
        let c = (min+max) / 2
        let delta = max - min
        centerPoint.setPositionFor(runtime, position: c)
        radius.setLengthFor(runtime, length: delta.length/2)
        
        angleUpperBound.setAngleFor(runtime, angle: ReformMath.angle(delta))
        
        angleLowerBound.setAngleFor(runtime, angle: ReformMath.angle(delta) - Angle.PI)
    }
    
    func getPathFor(runtime: Runtime) -> Path {
        return Path()
    }
    
    func getShapeFor(runtime: Runtime) -> Shape {
        return Shape()
    }
    
    func getPoints() -> [ExposedPointIdentifier:protocol<RuntimePoint,Labeled>] {
        return [
            ExposedPointIdentifier(0):AnchorPoint(anchor: lowerAnchor),
            ExposedPointIdentifier(1):AnchorPoint(anchor: upperAnchor),
            ExposedPointIdentifier(2):ExposedPoint(point: centerPoint, name: "Center"),
        ]
    }
    
    var rotator : Rotator {
        return CompositeRotator(rotators:
            BasicPointRotator(points: centerPoint),
            BasicAngleRotator(angles: angleUpperBound),
            BasicAngleRotator(angles: angleLowerBound)
        )
    }
    var scaler : Scaler {
        return CompositeScaler(scalers:
            BasicPointScaler(points: centerPoint),
            BasicLengthScaler(length: radius, angle: angleUpperBound)
        )
    }
    
    var translator : Translator {
        return BasicPointTranslator(points: centerPoint)
    }
    
    
    func getAnchors() -> [AnchorIdentifier:Anchor] {
        return [
            AnchorIdentifier(0):lowerAnchor,
            AnchorIdentifier(1):upperAnchor
        ]
    }
    
    var outline : Outline {
        return NullOutline()
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
        
        return c + rotate(Vec2d(x:r, y:r), angle: angle)
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