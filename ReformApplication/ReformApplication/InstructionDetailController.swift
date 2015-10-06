//
//  InstructionDetailController.swift
//  Reform
//
//  Created by Laszlo Korte on 06.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore

protocol InstructionDetailController : class {
    var stringifier : Stringifier? { set get }
    var error : String? { set get }
}