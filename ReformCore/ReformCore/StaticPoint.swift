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
        return Vec2d(x: Double(bitPattern: x), y:Double(bitPattern: y))
    }
    
    func setPositionFor<R:Runtime>(_ runtime: R, position: Vec2d) {
        runtime.write(formId, offset: offset, value: position.x.bitPattern)
        
        runtime.write(formId, offset: offset+1, value: position.y.bitPattern)
    }
}


extension StaticPoint : Equatable {

}


func ==(lhs: StaticPoint, rhs: StaticPoint) -> Bool {
    return lhs.formId == rhs.formId && lhs.offset == rhs.offset
}
