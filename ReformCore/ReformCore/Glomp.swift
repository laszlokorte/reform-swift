//
//  Glomp.swift
//  ReformCore
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformExpression

public struct GlompPoint : RuntimePoint, Labeled, Equatable {
    public let lerp : Expression
    public let formId : FormIdentifier
    
    public init(formId: FormIdentifier, lerp: Expression) {
        self.formId = formId
        self.lerp = lerp
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        let formName = stringifier.labelFor(formId) ?? "???"
        let value = stringifier.stringFor(lerp) ?? "??"
        
        return "\(value) along \(formName)"
    }
    
    public func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let formOutline = runtime.get(formId)?.outline else {
            return nil
        }
        
        guard case .Success(.DoubleValue(let l)) = lerp.eval(runtime.getDataSet()) else {
            return nil
        }
        
        return formOutline.getPositionFor(runtime, t: l)
    }
}


public func ==(lhs: GlompPoint, rhs: GlompPoint) -> Bool {
    return lhs.formId == rhs.formId && lhs.lerp == rhs.lerp
}