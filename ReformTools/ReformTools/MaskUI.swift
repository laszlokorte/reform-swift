//
//  PreviewUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 30.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public final class MaskUI {
    public enum State {
        case Disabled
        case Clip(x: Double, y: Double, width: Double, height: Double)
    }

    public var state : State = .Disabled

    public init() {}
}