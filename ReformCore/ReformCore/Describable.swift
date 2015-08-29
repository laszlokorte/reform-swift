//
//  Labeled.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public protocol Labeled {
    func getDescription(stringifier: Stringifier) -> String
}

public protocol Stringifier {
    func labelFor(formId: FormIdentifier) -> String?
    func labelFor(formId: FormIdentifier, pointId: ExposedPointIdentifier) -> String?

    func labelFor(formId: FormIdentifier, anchorId: AnchorIdentifier) -> String?

    func stringFor(expression: Expression) -> String?

}