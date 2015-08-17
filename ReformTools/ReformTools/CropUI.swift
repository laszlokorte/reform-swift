//
//  CropUI.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformStage

class CropUI {
    enum State {
        case Hide
        case Show([CropPoint])
        case Active(CropPoint, [CropPoint])
    }
    
    var state : State = .Hide
}