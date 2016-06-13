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
    case primary
    case secondary
}

extension PivotChoice {
    func pointFor(_ handle : AffineHandle) -> SnapPoint {
        switch self {
        case .primary:
            return handle.defaultPivot.0
        case .secondary:
            return handle.defaultPivot.1
        }
    }
}
