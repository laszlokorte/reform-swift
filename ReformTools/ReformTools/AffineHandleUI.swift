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
        case Hide
        case Show([AffineHandle])
        case Active(AffineHandle, [AffineHandle])
    }

    public var state : State = .Hide

    public init() {}
}