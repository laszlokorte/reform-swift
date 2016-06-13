//
//  GrabUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformStage

public final class GrabUI {
    public enum State {
        case hide
        case show([EntityPoint])
        case active(EntityPoint, [EntityPoint])
    }
    
    public var state : State = .hide
    
    public init() {}
}
