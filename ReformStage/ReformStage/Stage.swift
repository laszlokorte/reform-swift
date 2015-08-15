//
//  Stage.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformGraphics

class Stage {
    var entities : [Entity] = []
    var site : Vec2d = Vec2d()
    
    var currentShapes : [IdentifiedShape] = []
    var finalShapes : [IdentifiedShape] = []
    
    var intersections : [IntersectionPoint] = []
}


struct IdentifiedShape {
    let id : FormIdentifier
    let shape : Shape
}