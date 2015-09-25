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
    func initWithRuntime<R:Runtime>(runtime: R, form: Form) {
        formReference.setFormFor(runtime, form: form)
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

    var formReference : StaticFormReference {
        return StaticFormReference(formId: identifier, offset: 0)
    }

    public func getPoints() -> [ExposedPointIdentifier:LabeledPoint] {
        return [
            PointId.TopLeft.rawValue:ProxyPoint(formReference: formReference, side: .TopLeft),

            PointId.TopRight.rawValue:ProxyPoint(formReference: formReference, side: .TopRight),

            PointId.BottomLeft.rawValue:ProxyPoint(formReference: formReference, side: .BottomLeft),

            PointId.BottomRight.rawValue:ProxyPoint(formReference: formReference, side: .BottomRight),

            PointId.Top.rawValue:ProxyPoint(formReference: formReference, side: .Top),
            PointId.Bottom.rawValue:ProxyPoint(formReference: formReference, side: .Bottom),
            PointId.Right.rawValue:ProxyPoint(formReference: formReference, side: .Right),
            PointId.Left.rawValue:ProxyPoint(formReference: formReference, side: .Left),

            PointId.Center.rawValue:ProxyPoint(formReference: formReference, side: .Center)
        ]
    }

    public var outline : Outline {
        return ProxyOutline(formReference: formReference)
    }

}

extension ProxyForm : Rotatable {

    public var rotator : Rotator {
        return ProxyRotator(formReference: formReference)
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