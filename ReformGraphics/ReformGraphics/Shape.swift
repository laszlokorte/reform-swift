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
        background = .None
        stroke = .None
        area = .PathArea(Path())
    }
    
    public init(area : FillArea, background : Background = .None, stroke: Stroke = .None) {
        self.area = area
        self.stroke = stroke
        self.background = background
    }
}

public enum FillArea {
    case PathArea(Path)
    case TextArea(Vec2d, text: String, size: Double)
}

public enum Background {
    case Fill(Color)
    case None
}

public enum Stroke {
    case Solid(width: Double, color: Color)
    case None
}