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
    let lerp : Expression
    let form : FormIdentifier
    
    init(form: FormIdentifier, lerp: Expression) {
        self.form = form
        self.lerp = lerp
    }
    
    public func getDescription(analyzer: Analyzer) -> String {
        let formName = analyzer.get(form)?.name ?? "???"
        let value = analyzer.getExpressionPrinter().toString(lerp)
        
        return "#\(value) along \(formName)"
    }
    
    public func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let formOutline = runtime.get(form)?.outline else {
            return nil
        }
        
        guard case .Success(.DoubleValue(let l)) = lerp.eval(runtime.getDataSet()) else {
            return nil
        }
        
        return formOutline.getPositionFor(runtime, t: l)
    }
}