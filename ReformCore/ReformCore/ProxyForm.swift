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

extension ProxyForm {
    func initWithRuntime<R:Runtime>(_ runtime: R, form: Form) {
        formReference.setFormFor(runtime, form: form)
        angle.setAngleFor(runtime, angle: Angle())
    }
}

final public class ProxyForm : Form {
    public static var stackSize : Int = 2

    public let identifier : FormIdentifier
    public var name : String


    public init(id: FormIdentifier, name : String) {
        self.identifier = id
        self.name = name
    }

    var formReference : StaticFormReference {
        return StaticFormReference(formId: identifier, offset: 0)
    }

    public var angle : WriteableRuntimeRotationAngle {
        return StaticAngle(formId: identifier, offset: 1)
    }

    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.topLeft.rawValue:ProxyPoint(formReference: formReference, side: .topLeft, angle: angle),

            PointId.topRight.rawValue:ProxyPoint(formReference: formReference, side: .topRight, angle: angle),

            PointId.bottomLeft.rawValue:ProxyPoint(formReference: formReference, side: .bottomLeft, angle: angle),

            PointId.bottomRight.rawValue:ProxyPoint(formReference: formReference, side: .bottomRight, angle: angle),

            PointId.top.rawValue:ProxyPoint(formReference: formReference, side: .top, angle: angle),
            PointId.bottom.rawValue:ProxyPoint(formReference: formReference, side: .bottom, angle: angle),
            PointId.right.rawValue:ProxyPoint(formReference: formReference, side: .right, angle: angle),
            PointId.left.rawValue:ProxyPoint(formReference: formReference, side: .left, angle: angle),

            PointId.center.rawValue:ProxyPoint(formReference: formReference, side: .center, angle: angle)
        ]
    }

    public var outline : Outline {
        return ProxyOutline(formReference: formReference)
    }

}

extension ProxyForm {
    public func getFormIdForRuntime<R:Runtime>(_ runtime: R) -> FormIdentifier? {
        return formReference.getFormFor(runtime)?.identifier
    }
}

extension ProxyForm : Rotatable {

    public var rotator : Rotator {
        return CompositeRotator(rotators: ProxyRotator(formReference: formReference),             BasicAngleRotator(angles: angle))
    }
}

extension ProxyForm : Translatable {

    public var translator : Translator {
        return ProxyTranslator(formReference: formReference)

    }
}

extension ProxyForm : Scalable {

    public var scaler : Scaler {
        return ProxyScaler(formReference: formReference)
    }
}
