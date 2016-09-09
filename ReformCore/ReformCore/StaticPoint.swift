//
//  StaticPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct StaticPoint : WriteableRuntimePoint {
    fileprivate let formId : FormIdentifier
    fileprivate let offset : Int
    
    init(formId: FormIdentifier, offset: Int) {
        self.formId = formId
        self.offset = offset
    }
    
    func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            x = runtime.read(formId, offset: offset),
            let y = runtime.read(formId, offset: offset+1) else {
                return nil
        }
        return Vec2d(x: unsafeBitCast(x, to: Double.self), y:unsafeBitCast(y, to: Double.self))
    }
    
    func setPositionFor<R:Runtime>(_ runtime: R, position: Vec2d) {
        runtime.write(formId, offset: offset, value: unsafeBitCast(position.x, to: UInt64.self))
        
        runtime.write(formId, offset: offset+1, value: unsafeBitCast(position.y, to: UInt64.self))
    }
}


extension StaticPoint : Equatable {

}


func ==(lhs: StaticPoint, rhs: StaticPoint) -> Bool {
    return lhs.formId == rhs.formId && lhs.offset == rhs.offset
}
