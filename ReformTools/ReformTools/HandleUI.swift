//
//  HandleUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformStage

public class HandleUI {
    public enum State {
        case Hide
        case Show([Handle])
        case Active(Handle, [Handle])
    }
    
    public var state : State = .Hide
    
    public init() {}
}