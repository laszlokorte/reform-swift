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

final public class Stage {
    public internal(set) var entities : [Entity] = []
    public internal(set) var size : Vec2d = Vec2d()
    
    public internal(set) var currentShapes : [IdentifiedShape] = []
    public internal(set) var finalShapes : [IdentifiedShape] = []
    
    public internal(set) var intersections : [IntersectionSnapPoint] = []
    
    public init() {}
}


public struct IdentifiedShape {
    public let id : FormIdentifier
    public let shape : Shape
}