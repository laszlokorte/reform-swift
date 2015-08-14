//
//  ConstantLength.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

struct ConstantLength : RuntimeLength {
    private let length: Double
    
    init(length: Double) {
        self.length = length
    }
    
    func getLengthFor(runtime: Runtime) -> Double? {
        return length
    }
}