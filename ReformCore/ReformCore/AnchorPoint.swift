//
//  AnchorPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct AnchorPoint : RuntimePoint, Labeled {
    private let anchor : Anchor
    
    init(anchor: Anchor) {
        self.anchor = anchor
    }
    
    func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        return anchor.getPositionFor(runtime)
    }
    
    func getDescription(_ stringifier: Stringifier) -> String {
        return anchor.name
    }
}



extension AnchorPoint : Equatable {

}

func ==(lhs: AnchorPoint, rhs: AnchorPoint) -> Bool {
    return lhs.anchor.isEqualTo(rhs.anchor)
}
