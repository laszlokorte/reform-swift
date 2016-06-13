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
    func getDescription(_ stringifier: Stringifier) -> String
}

public protocol Stringifier {
    func labelFor(_ formId: FormIdentifier) -> String?
    func labelFor(_ formId: FormIdentifier, pointId: ExposedPointIdentifier) -> String?

    func labelFor(_ formId: FormIdentifier, anchorId: AnchorIdentifier) -> String?

    func stringFor(_ expression: ReformExpression.Expression) -> String?

}

extension Vec2d {
    var label : String {
        get {
            let fx = String(format: "%.2f", x)
            let fy = String(format: "%.2f", y)
            let z = -0.001...0.001

            if z.contains(x) == z.contains(y) {
                return "\(fx) horizontally, \(fy) vertically"
            } else if z.contains(y) {
                return "\(fx) horizontally"
            } else {
                return "\(fy) vertically"
            }
        }
    }
}
