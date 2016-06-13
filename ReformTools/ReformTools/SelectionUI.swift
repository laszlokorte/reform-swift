//
//  SelectionUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

public final class SelectionUI {
    public enum State {
        case hide
        case show(FormSelection)
    }

    public enum Rect {
        case hide
        case show(Vec2d, Vec2d)
    }
    
    public var state : State = .hide
    public var rect : Rect = .hide

    public init() {}
}
