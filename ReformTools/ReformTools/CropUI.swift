//
//  CropUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformStage

public class CropUI {
    public enum State {
        case Hide
        case Show([CropPoint])
        case Active(CropPoint, [CropPoint])
    }
    
    public var state : State = .Hide
    
    public init() {}
}