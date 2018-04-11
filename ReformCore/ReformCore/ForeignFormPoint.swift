//
//  ForeignFormPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct ForeignFormPoint : RuntimePoint, Labeled {
    public let formId : FormIdentifier
    public let pointId : ExposedPointIdentifier
    
    public init(formId: FormIdentifier, pointId: ExposedPointIdentifier) {
        self.formId = formId
        self.pointId = pointId
    }
    
    public func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            form = runtime.get(formId),
            let point = form.getPoints()[pointId] else {
            return nil
        }
        
        return point.getPositionFor(runtime)
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        let formName = stringifier.labelFor(formId) ?? "???"
        let pointName = stringifier.labelFor(formId, pointId: pointId) ?? "???"
        
        return "\(formName)'s \(pointName)"
        
    }
}

extension ForeignFormPoint : Equatable {

}


public func ==(lhs: ForeignFormPoint, rhs: ForeignFormPoint) -> Bool {
    return lhs.formId == rhs.formId && lhs.pointId == rhs.pointId
}

public struct AnonymousFormPoint : RuntimePoint {
    let formId : FormIdentifier
    let pointId : ExposedPointIdentifier
    
    public init(formId: FormIdentifier, pointId: ExposedPointIdentifier) {
        self.formId = formId
        self.pointId = pointId
    }
    
    public func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            form = runtime.get(formId),
            let point = form.getPoints()[pointId] else {
            return nil
        }
        
        return point.getPositionFor(runtime)
    }
}


extension AnonymousFormPoint : Equatable {

}


public func ==(lhs: AnonymousFormPoint, rhs: AnonymousFormPoint) -> Bool {
    return lhs.formId == rhs.formId && lhs.pointId == rhs.pointId
}
