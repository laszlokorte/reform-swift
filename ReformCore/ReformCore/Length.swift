//
//  Length.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

protocol RuntimeLength {
    func getLengthFor(runtime: Runtime) -> Double?
}

protocol WriteableRuntimeLength : RuntimeLength {
    func setLengthFor(runtime: Runtime, length: Double)
}