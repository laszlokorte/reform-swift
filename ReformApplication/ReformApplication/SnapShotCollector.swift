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

    private let maxSize : (Double, Double)
    private var currentSize : (Double, Double) = (0,0)
    private var currentScaled : (Double, Double) = (0,0)
    private(set) var snapshots = [InstructionNodeKey:NSImage]()
    private(set) var instructions = Set<InstructionNodeKey>()
    private(set) var errors = [InstructionNodeKey:RuntimeError]()
    private var errorsBuffer = [InstructionNodeKey:RuntimeError]()
    private(set) var paths = [Path]()

    let drawQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


    private var redraw = true

    public init(maxSize : (Double, Double)) {
        self.maxSize = maxSize
    }

    public func runtimeBeginEvaluation<R:Runtime>(runtime: R, withSize size: (Double, Double)) {
        paths.removeAll(keepCapacity: false)
        errorsBuffer.removeAll(keepCapacity: false)
        instructions.removeAll(keepCapacity: false)

        currentSize = (Double(size.0), Double(size.1))

        let scale = min(Double(maxSize.0)/Double(currentSize.0),
            Double(maxSize.1)/Double(currentSize.1))

        currentScaled = (
            scale * Double(size.0),
            scale * Double(size.1)
        )

    }

    public func runtimeFinishEvaluation<R:Runtime>(runtime: R) {
        swap(&errors, &errorsBuffer)
        self.redraw = false
    }

    public func runtime<R:Runtime>(runtime: R, didEval instruction: Evaluatable) {
        guard let instruction = instruction as? InstructionNode else {
            return
        }

        let key = InstructionNodeKey(instruction)

        guard !instructions.contains(key) else {
            return
        }


        instructions.insert(key)

        guard !instruction.isEmpty else {
            return
        }

        guard !instruction.isGroup else {
            return
        }

        guard !snapshots.keys.contains(key) || redraw else {
            return
        }

        let image = imageFor(key)


        if errorsBuffer.keys.contains(key) {
            dispatch_async(drawQueue) { [currentScaled, currentSize] in
                image.lockFocus()
                defer { image.unlockFocus() }
                let size = image.size
                guard let context =  NSGraphicsContext.currentContext()?.CGContext else {
                    return
                }

                CGContextClearRect(context, CGRect(origin: CGPoint(), size: size))

                CGContextSetLineWidth(context, 6)

                CGContextTranslateCTM(context,
                    (size.width -  CGFloat(currentScaled.0)) / 2,
                    (size.height - CGFloat(currentScaled.1)) / 2)
                CGContextScaleCTM(context, CGFloat(currentScaled.0 / currentSize.0), CGFloat(currentScaled.1 / currentSize.1))


                CGContextSetRGBFillColor(context, 1, 0.7, 0.6, 1)
                CGContextSetRGBStrokeColor(context, 0.8549, 0.1020, 0.0902, 1.0)
                CGContextFillRect(context, CGRect(x: 0, y: 0, width: currentSize.0, height: currentSize.1))
                CGContextStrokeRect(context, CGRect(x: 4, y: 4, width: currentSize.0-8, height: currentSize.1-8))
                
            }
            return
        }

        var currentPaths = [(guide: Bool, current: Bool, proxy: Bool, path: Path)]()


        func pushDrawable(drawable: Drawable, formId: FormIdentifier, proxy : Bool) {
            let isCurrent = instruction.target == formId
            let isGuide = drawable.drawingMode == .Guide

            guard isCurrent || !isGuide else {
                return
            }

            guard let path = drawable.getPathFor(runtime) else {
                return
            }

            currentPaths.append((guide: isGuide, current: isCurrent, proxy: proxy, path: path))
        }

        for formId in runtime.getForms() {
            let form = runtime.get(formId)

            if let drawable = form as? Drawable {
                pushDrawable(drawable, formId: formId, proxy: false)

            } else if let proxy = form as? ProxyForm {
                if let
                    proxyId = proxy.getFormIdForRuntime(runtime),
                    drawable = runtime.get(proxyId) as? Drawable {
                    pushDrawable(drawable, formId: formId, proxy: true)
                }
            }
        }


        dispatch_async(drawQueue) { [currentScaled, currentSize, paths, currentPaths] in
            image.lockFocus()
            defer { image.unlockFocus() }
            let size = image.size
            guard let context =  NSGraphicsContext.currentContext()?.CGContext else {
                return
            }

            CGContextClearRect(context, CGRect(origin: CGPoint(), size: size))

            CGContextSetLineWidth(context, 6)

            CGContextTranslateCTM(context,
                (size.width -  CGFloat(currentScaled.0)) / 2,
                (size.height - CGFloat(currentScaled.1)) / 2)
            CGContextScaleCTM(context, CGFloat(currentScaled.0 / currentSize.0), CGFloat(currentScaled.1 / currentSize.1))


            CGContextSetRGBFillColor(context, 1, 1, 1, 1)
            CGContextClipToRect(context, CGRect(x: 0, y: 0, width: currentSize.0, height: currentSize.1))

            CGContextFillRect(context, CGRect(x: 0, y: 0, width: currentSize.0, height: currentSize.1))

            CGContextSetRGBFillColor(context, 0.5,0.5,0.5,0.7)
            CGContextSetRGBStrokeColor(context, 0.6,0.6,0.6,1)

            for path in paths {
                path.draw(context)
            }
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)

            for (isGuide, isCurrent, isProxy, path) in currentPaths {
                if isProxy {
                    CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 0.7)
                    CGContextSetRGBStrokeColor(context, 0.7, 0.2, 0.7, 1)
                } else if isGuide {
                    CGContextSetRGBFillColor(context, 0, 0.9, 0.9, 0.7)
                    CGContextSetRGBStrokeColor(context, 0, 0.8, 0.8, 1)
                } else if isCurrent {
                    CGContextSetRGBFillColor(context, 0.1, 0.5, 0.9, 0.7)
                    CGContextSetRGBStrokeColor(context, 0, 0.4, 0.8, 1)
                } else {
                    CGContextSetRGBFillColor(context, 0.5,0.5,0.5, 0.7)
                    CGContextSetRGBStrokeColor(context, 0.4,0.4,0.4,1)
                }

                path.draw(context)
                CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            }
        }
    }

    func imageFor(key: InstructionNodeKey) -> NSImage {
        guard let image = snapshots[key] else {
            let image = NSImage(size: NSSize(width: CGFloat(maxSize.0), height: CGFloat(maxSize.1)))
            snapshots[key] = image
            return image
        }
        return image
    }

    public func runtime<R:Runtime>(runtime: R, exitScopeWithForms forms: [FormIdentifier]) {

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

    public func runtime<R:Runtime>(runtime: R, triggeredError: RuntimeError, on: Evaluatable) {
        guard let node = on as? InstructionNode else {
            return
        }
        errorsBuffer[InstructionNodeKey(node)] = triggeredError
    }

    func requireRedraw() {
        self.redraw = true
    }

}