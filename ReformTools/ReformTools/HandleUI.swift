//
//  HandleUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformStage

public final class HandleUI {
    public enum State {
        case hide
        case show([Handle])
        case active(Handle, [Handle])
    }
    
    public var state : State = .hide
    
    public init() {}
}
