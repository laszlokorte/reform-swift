//
//  Shape.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Shape {
    let background: Background
    let stroke: Stroke
    let path : Path
    
    public init() {
        background = .None
        stroke = .None
        path = Path()
    }
}

public enum Background {
    case Fill(Color)
    case None
}

public enum Stroke {
    case Solid(widht: Double, color: Color)
    case None
}