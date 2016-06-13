//
//  Alignment.swift
//  ReformCore
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public enum RuntimeAlignment {
    case leading
    case centered
}

extension RuntimeAlignment {
    func getMinMax(from: Vec2d, to: Vec2d) -> (min: Vec2d, max: Vec2d) {
        switch self {
        case .leading:
            return (min: from, max: to)
        case .centered:
            return (min: 2*from - to, max: to)
        }
    }
}
