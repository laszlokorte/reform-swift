//
//  Axis.swift
//  ReformCore
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public enum RuntimeAxis : Equatable {
    case None
    case Named(String, from: RuntimePoint, to: RuntimePoint)
}

extension RuntimeAxis {
    func getVectorFor<R:Runtime>(runtime: R) ->  Vec2d? {
        switch self {
        case .None: return Vec2d()
        case  .Named(_, let from, let to):
            guard let
                start = from.getPositionFor(runtime),
                end = to.getPositionFor(runtime) else {
                    return nil
            }
            
            return normalize((end - start))
        }
    }
}

public func ==(lhs: RuntimeAxis, rhs: RuntimeAxis) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None): return true
    case (.Named(let nameA, let fromA, let toA),.Named(let nameB, let formB, let toB)):
        return nameA == nameB && fromA.isEqualTo(formB) && toA.isEqualTo(toB)
    default: return false
    }
}