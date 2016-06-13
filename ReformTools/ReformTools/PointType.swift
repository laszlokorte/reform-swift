//
//  PointType.swift
//  ReformTools
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

struct PointType : OptionSet {
    let rawValue : Int
    
    static let Any = PointType(rawValue: 1|2|4)
    static let None = PointType(rawValue: 0)
    static let Form = PointType(rawValue: 1)
    static let Intersection = PointType(rawValue: 2)
    static let Glomp = PointType(rawValue: 4)
    static let Grid = PointType(rawValue: 8)
}
