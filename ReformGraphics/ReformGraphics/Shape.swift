//
//  Shape.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct Shape {
    let background: Background
    let stroke: Stroke
    let area : FillArea
    
    public init() {
        background = .none
        stroke = .none
        area = .pathArea(Path())
    }
    
    public init(area : FillArea, background : Background = .none, stroke: Stroke = .none) {
        self.area = area
        self.stroke = stroke
        self.background = background
    }
}

public enum Aligment {
    case left
    case right
    case center
}

public enum FillArea {
    case pathArea(Path)
    case textArea(Vec2d, Vec2d, alignment: Aligment, text: String, size: Double)
}

public enum Background {
    case fill(Color)
    case none
}

public enum Stroke {
    case solid(width: Double, color: Color)
    case none
}
