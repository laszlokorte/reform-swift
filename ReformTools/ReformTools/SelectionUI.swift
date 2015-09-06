//
//  SelectionUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

public class SelectionUI {
    public enum State {
        case Hide
        case Show(FormSelection)
    }

    public enum Rect {
        case Hide
        case Show(Vec2d, Vec2d)
    }
    
    public var state : State = .Hide
    public var rect : Rect = .Hide

    public init() {}
}