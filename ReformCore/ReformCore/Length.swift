//
//  Length.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol RuntimeLength {
    func getLengthFor(runtime: Runtime) -> Double?
}

public protocol WriteableRuntimeLength : RuntimeLength {
    func setLengthFor(runtime: Runtime, length: Double)
}