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

}


public class Aligner {
    var state : AlignmentMode = .Aligned
    
    public init() {}
    
    func setMode(alignment: AlignmentMode) {
        state = alignment
    }
    
    func getAlignment() -> RuntimeAlignment {
        switch state {
        case .Centered: return .Centered
        case .Aligned: return .Leading
        }
    }
}