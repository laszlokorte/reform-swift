//
//  Project.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final public class Project {
    public private(set) var pictures : [Picture]
    
    public init(pictures: Picture...) {
        self.pictures = pictures
    }

    public init(pictures: [Picture]) {
        self.pictures = pictures
    }
}