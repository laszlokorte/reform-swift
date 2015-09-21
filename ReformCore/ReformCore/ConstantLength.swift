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
    
    func getLengthFor<R:Runtime>(runtime: R) -> Double? {
        return length
    }
}

extension ConstantLength : Equatable {
}

func ==(lhs: ConstantLength, rhs: ConstantLength) -> Bool {
    return lhs.length == rhs.length
}