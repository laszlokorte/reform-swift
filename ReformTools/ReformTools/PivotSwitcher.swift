//
//  PivotSwitcher.swift
//  ReformTools
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformCore
import ReformStage

public enum PivotChoice {
    case Primary
    case Secondary
}

extension PivotChoice {
    func pointFor(handle : AffineHandle) -> SnapPoint {
        switch self {
        case .Primary:
            return handle.defaultPivot.0
        case .Secondary:
            return handle.defaultPivot.1
        }
    }
}