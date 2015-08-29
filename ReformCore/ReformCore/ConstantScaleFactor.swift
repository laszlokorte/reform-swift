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
    
    public func getFactorFor(runtime: Runtime) -> Double? {
        return factor
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        return String(format: "%.2f%%", factor * 100)
    }
    
    public func isDegenerated() -> Bool {
        return factor == 0
    }
}