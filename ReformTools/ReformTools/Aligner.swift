//
//  Alignment.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore

enum AlignmentMode {
    case centered
    case aligned

}


public final class Aligner {
    var state : AlignmentMode = .aligned
    
    public init() {}
    
    func setMode(_ alignment: AlignmentMode) {
        state = alignment
    }
    
    func getAlignment() -> RuntimeAlignment {
        switch state {
        case .centered: return .centered
        case .aligned: return .leading
        }
    }
}
