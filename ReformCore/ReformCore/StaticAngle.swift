//
//  StaticAngle.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//
import ReformMath

struct StaticAngle : WriteableRuntimeRotationAngle {
    fileprivate let formId : FormIdentifier
    fileprivate let offset : Int
    
    init(formId: FormIdentifier, offset: Int) {
        self.formId = formId
        self.offset = offset
    }
    
    func getAngleFor<R:Runtime>(_ runtime: R) -> Angle? {
        guard let l = runtime.read(formId, offset: offset) else {
            return nil
        }
        
        return normalize360(Angle(radians: unsafeBitCast(l, to: Double.self)))
    }
    
    func setAngleFor<R:Runtime>(_ runtime: R, angle: Angle) {
        runtime.write(formId, offset: offset, value: unsafeBitCast(normalize360(angle).radians, to: UInt64.self))
    }

    var isDegenerated : Bool {
        return false
    }
}

extension StaticAngle : Equatable {
}

func ==(lhs: StaticAngle, rhs: StaticAngle) -> Bool {
    return lhs.formId == rhs.formId && lhs.offset == rhs.offset
}
