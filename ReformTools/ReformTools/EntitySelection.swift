//
//  EntitySelection.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

public class EntitySelection {
    public var selected : Entity?
    
    public init() {}
}


extension EntitySelection {
    public func isSelected(entity: Entity) -> Bool {
        return false
    }
}