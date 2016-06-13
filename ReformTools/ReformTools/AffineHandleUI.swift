//
//  AffineHandleUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformCore
import ReformStage

public final class AffineHandleUI {
    public enum State {
        case hide
        case show([AffineHandle])
        case active(AffineHandle, [AffineHandle])
    }

    public var state : State = .hide

    public init() {}
}
