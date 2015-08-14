//
//  ForeignFormPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct ForeignFormPoint : RuntimePoint, Labeled {
    let formId : FormIdentifier
    let pointId : ExposedPointIdentifier
    
    init(formId: FormIdentifier, pointId: ExposedPointIdentifier) {
        self.formId = formId
        self.pointId = pointId
    }
    
    func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let form = runtime.get(formId), let point = form.getPoints()[pointId] else {
            return nil
        }
        
        return point.getPositionFor(runtime)
    }
    
    func getDescription(analyzer: Analyzer) -> String {
        let form = analyzer.get(formId)
        let formName = form?.name ?? "???"
        let pointName = form?.getPoints()[pointId]?.getDescription(analyzer) ?? "??"
        
        return "\(formName)'s \(pointName)"
    
    }
}