//
//  SelectionUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore

public class SelectionUI {
    public enum State {
        case Hide
        case Show(EntitySelection)
    }
    
    public var state : State = .Hide
    
    public init() {}
}