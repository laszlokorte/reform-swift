//
//  SnapPoint.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore

public protocol SnapPoint {
    var position :  Vec2d { get }
    var label : String { get }
    
    var runtimePoint : LabeledPoint { get }
    
    func belongsTo(_ formId: FormIdentifier) -> Bool
    
    func equals(_ other: SnapPoint) -> Bool
}

extension SnapPoint where Self : Equatable {
    public func equals(_ other: SnapPoint) -> Bool {
        guard let o = other as? Self else {
            return false
        }
        
        return o == self
    }
}
