//
//  Glomp.swift
//  ReformCore
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformExpression

public struct GlompPoint : RuntimePoint, Labeled {
    public let lerp : Expression
    public let formId : FormIdentifier
    
    public init(formId: FormIdentifier, lerp: Expression) {
        self.formId = formId
        self.lerp = lerp
    }
    
    public func getDescription(analyzer: Analyzer) -> String {
        let formName = analyzer.get(formId)?.name ?? "???"
        let value = analyzer.getExpressionPrinter().toString(lerp)
        
        return "#\(value) along \(formName)"
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