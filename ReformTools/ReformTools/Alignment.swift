//
//  Alignment.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore

enum AlignmentMode {
    case Centered
    case Aligned
    
    var runtimeAlignment : RuntimeAlignment {
        switch self {
        case .Centered: return .Centered
        case .Aligned: return .Leading
        }
    }
}