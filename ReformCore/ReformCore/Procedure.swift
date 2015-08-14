//
//  Procedure.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

class Procedure {
    let root : InstructionGroup = InstructionGroupBase()
    private let paper = Paper()
}

extension Procedure {
    func evaluateWith(runtime: Runtime) {
        runtime.run() { width, height in
            runtime.scoped() {
                runtime.declare(self.paper)
                self.paper.initWithRuntime(runtime, min: Vec2d(), max: Vec2d(x:Double(width), y: Double(height)))
                self.root.evaluate(runtime)
            }
        }
    }
}