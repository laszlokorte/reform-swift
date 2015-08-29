//
//  SnapShotCollector.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics
import ReformCore

struct InstructionNodeKey : Hashable {
    private let node : InstructionNode

    init(_ instructionNode : InstructionNode) {
        node = instructionNode
    }

    var hashValue : Int {
        return ObjectIdentifier(node).hashValue
    }
}

func ==(lhs: InstructionNodeKey, rhs: InstructionNodeKey) -> Bool {
    return lhs.node === rhs.node
}

final public class SnapshotCollector : RuntimeListener {

    private let maxSize : (Int, Int)
    private var currentSize : (Int, Int) = (0,0)
    private var currentScaled : (Double, Double) = (0,0)
    private(set) var snapshots = [InstructionNodeKey:NSImage]()
    private(set) var instructions = Set<InstructionNodeKey>()
    private(set) var errors = [InstructionNodeKey:RuntimeError]()
    private(set) var paths = [Path]()


    private var redraw = true

    public init(maxSize : (Int, Int)) {
        self.maxSize = maxSize
    }

    public func runtimeBeginEvaluation(runtime: Runtime, withSize size: (Int, Int)) {
        paths.removeAll()
        errors.removeAll()
        instructions.removeAll()

        if currentSize.0 != size.0 || currentSize.1 != size.1 {
            snapshots.removeAll()
            currentSize = size
            let scale = min(Double(maxSize.0)/Double(currentSize.0),
                Double(maxSize.1)/Double(currentSize.1))

            currentScaled = (
                scale * Double(size.0),
                scale * Double(size.1)
            )
        }
    }

    public func runtimeFinishEvaluation(runtime: Runtime) {
    }

    public func runtime(runtime: Runtime, didEval instruction: Evaluatable) {
        guard let instruction = instruction as? InstructionNode else {
            return
        }

        let key = InstructionNodeKey(instruction)

        guard !instruction.isEmpty else {
            return
        }

        guard !instruction.isGroup else {
            return
        }

        guard !errors.keys.contains(key) else {
            return
        }

        guard !snapshots.keys.contains(key) || redraw else {
            return
        }

        let image = imageFor(key)


        do {
            image.lockFocus()
            defer { image.unlockFocus() }
            let size = image.size
            guard let context =  NSGraphicsContext.currentContext()?.CGContext else {
                return
            }

            NSColor.whiteColor().setFill()
            NSRectFill(NSRect(origin: CGPoint(), size: size))

            CGContextScaleCTM(context, size.width / CGFloat(currentSize.0), size.height / CGFloat(currentSize.1))


            NSColor.grayColor().setFill()
            NSColor.grayColor().set()
            CGContextSetLineWidth(context, 9)
            for path in paths {
                path.draw(context)
                CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            }

            for formId in runtime.getForms() {
                guard let form = runtime.get(formId) as? Drawable else {
                    continue
                }
                let isCurrent = instruction.target == formId
                let isGuide = form.drawingMode == .Guide

                guard isCurrent || !isGuide else {
                    continue
                }

                guard let path = form.getPathFor(runtime) else {
                    continue
                }
                if isGuide {
                    NSColor.cyanColor().setFill()
                    NSColor.cyanColor().set()
                } else if isCurrent {
                    NSColor.blueColor().setFill()
                    NSColor.blueColor().set()
                } else {
                    NSColor.grayColor().setFill()
                    NSColor.grayColor().set()
                }

                path.draw(context)
                CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            }
        }
    }

    func imageFor(key: InstructionNodeKey) -> NSImage {
        guard let image = snapshots[key] else {
            let image = NSImage(size: NSSize(width: CGFloat(currentScaled.0), height: CGFloat(currentScaled.1)))
            snapshots[key] = image
            return image
        }
        return image
    }

    public func runtime(runtime: Runtime, exitScopeWithForms forms: [FormIdentifier]) {

        for formId in forms {
            guard let form = runtime.get(formId) as? Drawable else {
                continue
            }

            guard form.drawingMode == .Draw else {
                continue
            }

            guard let path = form.getPathFor(runtime) else {
                continue
            }

            paths.append(path)
        }

    }

    public func runtime(runtime: Runtime, triggeredError: RuntimeError, on: Evaluatable) {
        guard let node = on as? InstructionNode else {
            return
        }
        errors[InstructionNodeKey(node)] = triggeredError
    }

    func requireRedraw() {
        self.redraw = true
    }

}