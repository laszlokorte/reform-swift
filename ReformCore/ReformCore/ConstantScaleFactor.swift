//
//  ConstantScaleFactor.swift
//  ReformCore
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation


public struct ConstantScaleFactor : RuntimeScaleFactor, Labeled {
    private let factor: Double
    
    public init(factor: Double) {
        self.factor = factor
    }
    
    public func getFactorFor<R:Runtime>(_ runtime: R) -> Double? {
        return factor
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        return String(format: "%.2f%%", factor * 100)
    }
    
    public var isDegenerated : Bool {
        return factor == 1
    }
}

func combine(factor a: ConstantScaleFactor, factor b: ConstantScaleFactor) -> ConstantScaleFactor {
    return ConstantScaleFactor(factor: a.factor * b.factor)
}
