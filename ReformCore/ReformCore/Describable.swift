//
//  Labeled.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression
import ReformMath

public protocol Labeled {
    func getDescription(stringifier: Stringifier) -> String
}

public protocol Stringifier {
    func labelFor(formId: FormIdentifier) -> String?
    func labelFor(formId: FormIdentifier, pointId: ExposedPointIdentifier) -> String?

    func labelFor(formId: FormIdentifier, anchorId: AnchorIdentifier) -> String?

    func stringFor(expression: Expression) -> String?

}

extension Vec2d {
    var label : String {
        get {
            let fx = String(format: "%.2f", x)
            let fy = String(format: "%.2f", y)
            let z = -0.001...0.001

            if z.contains(x) == z.contains(y) {
                return "\(fx) Horizontally, \(fy) Vertically"
            } else if z.contains(y) {
                return "\(fx) Horizontally"
            } else {
                return "\(fy) Vertically"
            }
        }
    }
}